/*
 * foobot - slogans plugin
 *
 * Copyright (c) 2011, Christoph Mende <mende.christoph@gmail.com>
 * All rights reserved. Released under the 2-clause BSD license.
 */


using Foobot;

public class Slogans : Object, Plugin {
	string[] cornholio_slogans = { "Are you threatening me?",
                "I AM THE GREAT CORNHOLIO!",
                "Do you have TP?",
                "TP for my bunghole!",
                "DO NOT MAKE MY BUNGHOLE ANGRY!",
                "You will give me TP, bungholio!",
                "My bunghole will not wait!",
                "You do not want to face the wrath of my bunghole!",
                "You have awakened my bunghole and now you must pay!",
                "Come out with your pants down!",
                "You must bow down to the almighty bunghole!",
                "You can take me, but you cannot take my bunghole!",
                "I shall claim this land for my bunghole!",
                "Where I come from, there is no TP!",
                "Where I come from, we have no bunghole!",
                "I need crappucino for my bunghole!",
                "I have no bunghole!",
                "You will give me all your caca!",
                "I am bungholio!",
                "Do not underestimate the power of the almighty bunghole!",
                "I am Cornholio, guardian of the Great Bunghole!",
                "Thank you drive thru",
                "Would you like some fries with that?",
                "I NEED TP FOR MY BUNGHOLE",
                "BUNGHOLE",
                "Cool.",
                "That sucked.",
                "That rules.",
                "Hey, how's it going?",
                "I need more coffee!",
                "BUNGHOLIO",
                "There will be T.P. for everyone!" };

	string[] futurama_slogans = { "IN COLOR",
                "IN HYPNO-VISION",
                "AS SEEN ON TV",
                "presented in BC [Brain Control] where available",
                "Featuring GRATIOUS ALIEN NUDITY",
                "LOADING..",
                "PRESENTED IN DOUBLE VISION (WHERE DRUNK)",
                "Mr. Bender's Wardrobe by ROBOTANY 500",
                "Condemned by the Space Pope",
                "Filmed On Location",
                "Transmitido en Martian en SAP",
                "-=PROUDLY MADE ON EARTH=-",
                "LIVE FROM OMICRON PERSEI 8",
                "MADE FROM MEAT BY-PRODUCTS",
                ">>NOT Y3K COMPLIANT<<",
                "FROM THE MAKERS OF FUTURAMA",
                "Based on a true Story",
                "From the network that brought you \"The Simpsons\"",
                "Not Based On the Novel by James Fenimore Cooper",
                "THE SHOW THAT WATCHES BACK",
                "Nominated For Three Glemmys",
                "This Episode Has Been Modified To Fit Your Primitive Screen",
                "COMING SOON TO AN ILLEGAL DVD",
                "As Foretold by Nostradamus",
                "A Stern Warning of Things to Come",
                "SIMULCAST ON CRAZY PEOPLE'S FILLINGS",
                "LARVA-TESTED, PUPA-APPROVED",
                "FOR EXTERNAL USE ONLY",
                "PAINSTACKINGLY DRAWN BEFORE A LIVE AUDIENCE",
                "TOUCH EYEBALLS TO SCREEN FOR CHEAP LASER SURGERY",
                "SMELL-O-VISION USERS INSERT NOSTRIL TUBES NOW",
                "Not a Substitute for Human Interaction",
                "Secreted by the Comedy Bee",
                "IF NOT ENTERTAINING; WRITE YOUR CONGRESSMAN",
                "BROADCAST SIMULTANEOUSLY ONE YEAR IN THE FUTURE",
                "Now With Chucklelin",
                "TORN FROM TOMORROW'S HEADLINES",
                "80% ENTERTAINMENT BY VOLUME",
                "DECIPHERED FROM CROP CIRCLES",
                "PLEASE RISE FOR THE FUTURAMA THEME SONG",
                "Bender's Humor by Microsoft Joke",
                "FEDERAL LAW PROHIBITS CHANGING THE CHANNEL",
                "FOR PROPER VIEWING, TAKE RED PILL NOW",
                "NO HUMANS WHERE PROBED IN THE MAKING OF THIS EPISODE",
                "FUN FOR THE WHOLE FAMILY EXCEPT GRANDMA AND GRANDPA" };

	public void init()
	{
		register_command("cornholio");
		register_command("futurama");
		irc.joined.connect(cornholio_join);
	}

	public string cornholio(string channel, User user)
	{
		var idx = Random.int_range(0, cornholio_slogans.length - 1);
		return cornholio_slogans[idx];
	}

	public string futurama(string channel, User user)
	{
		var idx = Random.int_range(0, futurama_slogans.length - 1);
		return futurama_slogans[idx];
	}

	public string? cornholio_join(string channel, User user)
	{
		if (user.nick == Foobot.Settings.nick) {
			var idx = Random.int_range(0, cornholio_slogans.length - 1);
			return cornholio_slogans[idx];
		} else {
			return null;
		}
	}
}

public Type register_plugin()
{
	return typeof(Slogans);
}

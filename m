Received: (from uucp@localhost)
	by annwfn.erfurt.thur.de (8.9.3/8.9.2) with UUCP id SAA29727
	for linux-mm@kvack.org; Mon, 27 Mar 2000 18:06:01 +0200
Received: from nibiru.pauls.erfurt.thur.de (uucp@localhost)
	by pauls.erfurt.thur.de (8.9.3/8.9.3) with bsmtp id RAA04127
	for linux-mm@kvack.org; Mon, 27 Mar 2000 17:55:27 +0200
Received: from nibiru.pauls.erfurt.thur.de (localhost [127.0.0.1])
	by nibiru.pauls.erfurt.thur.de (8.9.3/8.9.3) with ESMTP id MAA06805
	for <linux-mm@kvack.org>; Mon, 27 Mar 2000 12:50:10 GMT
Message-ID: <38DF5901.CEBF90B0@nibiru.pauls.erfurt.thur.de>
Date: Mon, 27 Mar 2000 12:50:09 +0000
From: Enrico Weigelt <weigelt@nibiru.pauls.erfurt.thur.de>
Reply-To: weigelt@nibiru.pauls.erfurt.thur.de
MIME-Version: 1.0
Subject: compressed swap 
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

hi,

i'm currenty thinking about a compressed swapspace-manager.
not to save diskspace, but to reduce the IO-upcome.

in today's PCs the blottleneck is the disk-bandwith when the
system is swapping. (okay, people could buy more ram ... hmmm :()

i'm quite new to the linux-mm - so how should i start ?

bye,
ew.
-------------------------------------------------------------------------------
KAMPF GEGEN ECHOLON - DIE USA SCHNEIDED WELTWEIT DEN EMAIL-VERKEHR
MIT!!!
BITTE ALLE MITMACHEN UND "GEFAEHRLICHE" WOERTER IN DIE SIGNATUR
SCHREIBEN
...
againstNSAletskillthemallaufstanddollarwirtschaftskrieseusakillthepresident
shitfuckingusawewillattacknextweekterrorecholonforkommunismagainstdemocracy.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

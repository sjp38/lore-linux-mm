Received: (from uucp@localhost)
	by annwfn.erfurt.thur.de (8.9.3/8.9.2) with UUCP id SAA29730
	for linux-mm@kvack.org; Mon, 27 Mar 2000 18:06:01 +0200
Received: from nibiru.pauls.erfurt.thur.de (uucp@localhost)
	by pauls.erfurt.thur.de (8.9.3/8.9.3) with bsmtp id RAA04129
	for linux-mm@kvack.org; Mon, 27 Mar 2000 17:55:27 +0200
Received: from nibiru.pauls.erfurt.thur.de (localhost [127.0.0.1])
	by nibiru.pauls.erfurt.thur.de (8.9.3/8.9.3) with ESMTP id OAA11790
	for <linux-mm@kvack.org>; Mon, 27 Mar 2000 14:58:21 GMT
Message-ID: <38DF770C.A5BD2999@nibiru.pauls.erfurt.thur.de>
Date: Mon, 27 Mar 2000 14:58:21 +0000
From: Enrico Weigelt <weigelt@nibiru.pauls.erfurt.thur.de>
Reply-To: weigelt@nibiru.pauls.erfurt.thur.de
MIME-Version: 1.0
Subject: what's about /sbin/update ?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

hello folks,

am i right - the work of bdflush is now kflushd ?
(since we have kernel threads)

but why do i still have an update(bdflush) running ?

correct me if i'm wrong, but isn't bdflush() now only used 
to configure some parameters of the kflushd and should 
always return ?

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

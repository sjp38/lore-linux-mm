Message-ID: <38DF56FE.107E9D0E@nibiru.pauls.erfurt.thur.de>
Date: Mon, 27 Mar 2000 12:41:34 +0000
From: Enrico Weigelt <weigelt@nibiru.pauls.erfurt.thur.de>
Reply-To: weigelt@nibiru.pauls.erfurt.thur.de
MIME-Version: 1.0
Subject: kernel-config modules
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@kvack.org
List-ID: <linux-mm.kvack.org>

what do you think about configuration modules instead of
big-fat configuration interfaces (especially for lowmem-machines).

imagine this: 

parts of the kernel (or modules) export the configurable structures
and there are modules which take the params and configure the stuff.
after doing it, they're killed again.

with this concept drivers could be splitted in two parts: (modules)
a resident and a non-resident one.

the resident part is the real driver code. the non resident one
does the initialization, detection, configuration, etc.
after these things are done, the non-resident part is not needed
anylonger and can be kicked away.

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

Received: from agnes.fremen.dune (bas5-12.idf7-1.club-internet.fr [195.36.255.12])
	by front3.grolier.fr (8.9.3/No_Relay+No_Spam_MGC990224) with SMTP id VAA15550
	for <linux-mm@kvack.org>; Tue, 6 Feb 2001 21:24:22 +0100 (MET)
Message-Id: <200102062024.VAA15550@front3.grolier.fr>
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From: Jean Francois Martinez <jfm2@club-internet.fr>
Subject: Another Mindcradt case?
Date: 06 Feb 2001 21:25:10 CET
Reply-To: Jean Francois Martinez <jfm2@club-internet.fr>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Moshe Barr is claiming on Byte that sendmail and mysql are 30% faster on
FreeBSD than Linux 2.4.   Now given that I don't think that mysql is spending
30% of its time in kernel mode there are not many ways FreeBSD can be 30%
faster.

1) Compiler issues.  Moshe Barr does not tell what distrib ha was using so we
don't know what distribution was used and with what 

2) Driver problems, specally those related to enabling UltraDma since without
UltraDMA most disks are both very slow and CPU hogs.

3) Options not enabled.  This a 2.2 Linux distrib with a 2.4 keernel plastered
on it and thus software has not been compiled to take advantage of 2.4bfeatures
and the boot sequence does not do a good job of tuning the kernel through
sysctl

4) Memory management.  If FreeBSD is smarter than Linux about which page to
thow out it will be _much_ faster when memory is tight.


Now what about a Mindcraft-style reaction?  Check what was wrong in the test
protocol, write an answer if it was due to the test and in case it was not the
test but a perfomance bottleneck fix it.

Moshe (and a few other people will do the same) was wondering why to stay with
Linux so better fix the problems if we want Linux and not BSD reaching world
domination. 


									JF
Martinez
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

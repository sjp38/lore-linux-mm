Received: from front7.grolier.fr (front7.grolier.fr [194.158.96.57])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA20870
	for <linux-mm@kvack.org>; Thu, 19 Nov 1998 01:10:09 -0500
Received: from sidney.remcomp.fr (ppp-166-128.villette.club-internet.fr [195.36.166.128])
	by front7.grolier.fr (8.9.0/MGC-980407-Frontal-No_Relay) with SMTP id HAA24446
	for <linux-mm@kvack.org>; Thu, 19 Nov 1998 07:10:00 +0100 (MET)
Date: 19 Nov 1998 00:20:37 -0000
Message-ID: <19981119002037.1785.qmail@sidney.remcomp.fr>
From: jfm2@club-internet.fr
Subject: Two naive questions and a suggestion
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


1) Is there any text describing memory management in 2.1?  (Forgive me
   if I missed an obvious URL)

2) Are there plans for implementing the swapping of whole processes a
   la BSD?

Suggestion: Given that the requiremnts for a workstation (quick
response) are different than for a server (high throughput) it could
make sense to allow the user either use /proc for selecting the VM
policy or have a form of loadable VM manager.  Or select it at compile
time.

-- 
			Jean Francois Martinez

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

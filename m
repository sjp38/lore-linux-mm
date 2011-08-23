Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 912406B016A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 02:51:51 -0400 (EDT)
Received: from localhost (localhost [127.0.0.1])
	by uplift.swm.pp.se (Postfix) with ESMTP id 3AEC69A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 08:51:48 +0200 (CEST)
Date: Tue, 23 Aug 2011 08:51:48 +0200 (CEST)
From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: copying files stops after a while in laptop mode on 2.6.38
Message-ID: <alpine.DEB.2.00.1108230822480.4709@uplift.swm.pp.se>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Hi.

I'm running ubuntu 11.04 on my thinkpad X200 laptop with their 2.6.38 
kernel. Whenever I copy a lot of data to my harddrive without the power 
connected (cryptsetup:ed drive and ubuntus eCryptfs for home directory 
(yeah I know, that's two levels of encryption))) the copy stops after 
500-1000 megabyte. It'll just sit there, nothing more happening, my 
firefox goes into blocking (greys out). If I then issue a "sync" command 
in the terminal, things resume just as normal, until another 500-1000 
megabyte has been copied. This doesn't happen if I have the power cable 
connected.

I interpret this as when the laptop is in laptop-mode, it doesn't flush 
data to drive when memory is "full". Is this a known problem with 2.6.38 
kernel, or might it be something ubuntu specific? I find it strange that 
not more people are hit by this...

Any thoughts?

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

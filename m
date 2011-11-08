Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D690D6B002D
	for <linux-mm@kvack.org>; Tue,  8 Nov 2011 04:29:00 -0500 (EST)
Date: Tue, 8 Nov 2011 10:28:57 +0100 (CET)
From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: mdraid write performance in different kernels up to 3.0, 3.0 shows
 huge improvement
Message-ID: <alpine.DEB.2.00.1111081019010.19721@uplift.swm.pp.se>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-raid@vger.kernel.org


Hello.

I have been running mdraid->cryptsetup/LUKS->lvm->xfs on Ubuntu AMD64 with 
RAID5 and now RAID6 for quite some time, dating back to 2.6.27. Around 
2.6.32 I saw quite a bit of regression in write performance (probably the 
implementation of barriers), 2.6.35 was acceptable, 2.6.38 was really 
really bad, and 3.0 is like a rocket. Best of them all.

I'm talking about 10-20x in different in write performance on my workload, 
in combination with the older kernels throwing me page allocation failures 
when the write load gets high, and also quite often the machine would just 
freeze up and had to be rebooted.

With 2.6.38 I was down to 6-10 megabyte/s write speed, whereas 3.0 seem to 
give me 100+ megabyte/s with the exact same workload, I've seen up to 150 
megabyte/s writes at good times. This is on a box with AES-NI, so the 
crypto is not the limiting factor.

I have from time to time sent out an email regarding my page allocation 
failures, but never really got any takers on trying to fault find it, my 
tickets with ubuntu also never got any real attention. I haven't really 
pushed it super hard with 3.0, but I've thrown loads at it that would make 
2.6.38 lock up.

Just wanted to send in this success report that this finally seem to have 
seen some really nice improvements!

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from 192.168.57.15 (a2 [192.168.57.22])
	by WS0005.indiatimes.com (8.9.3/8.9.3) with SMTP id WAA29840
	for <linux-mm@kvack.org>; Thu, 14 Feb 2002 22:34:12 +0530
From: "prodyuth" <prodyuth@indiatimes.com>
Message-Id: <200202141704.WAA29840@WS0005.indiatimes.com>
Reply-To: "prodyuth" <prodyuth@indiatimes.com>
Subject: Does mmap make a memory copy?
Date: Thu, 14 Feb 2002 22:46:17 +0530
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,
I would be very thankful if anyone confirms my understanding of mmap.

I am using mmap to attach a device buffer into the process virtual address space. My understanding is that there will not be a kernel copy of the device buffer.
So writing into the process address space is like writing into the device buffer directly without a memory copy.

Am I correct in my understanding.

Thanks in advance for your help.
Regards,
Prodyut.




Get Your Private, Free E-mail from Indiatimes at http://email.indiatimes.com

 Buy Music, Video, CD-ROM, Audio-Books and Music Accessories from http://www.planetm.co.in


Get Your Private, Free E-mail from Indiatimes at http://email.indiatimes.com

 Buy Music, Video, CD-ROM, Audio-Books and Music Accessories from http://www.planetm.co.in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

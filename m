From: THE INFAMOUS <evil7@seifried.org>
Reply-To: evil7@seifried.org
Subject: Latest VM patch autotuning
Date: Fri, 2 Jun 2000 06:52:27 -0500
Content-Type: text/plain
MIME-Version: 1.0
Message-Id: <00060206562100.00719@sQa.speedbros.org>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

I patched up.... Did some stress test.... And I am quite impressed.....
rephrase I am very impressed

During an X session with helix-gnome + sawfish, 3 Eterms, balsa, netscape, 'cp
-af /usr/src/linux /mnt/backup' && updatedb I saw a max load average of 1.28,
physical memory peaked, swaped out about 3 megs during the stress test, and
afterwards everything recovered like a champ(including my physical memory). 

Very very impressed.

Keep up the good work : )

-- 
Bryan Paxton

"I don't need to sleep or eat, I'll smoke a thousand cigarettes."
- Sebadoh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

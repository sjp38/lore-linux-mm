From: THE INFAMOUS <evil7@seifried.org>
Reply-To: evil7@seifried.org
Subject: 24t1ac7-kswapdtune3
Date: Sat, 3 Jun 2000 17:44:51 -0500
Content-Type: text/plain
MIME-Version: 1.0
Message-Id: <00060317493000.00609@sQa.speedbros.org>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Did a usual stress test :


X + gnome + sawfish + 3 Eterms + balsa + netscape + cp -af
          /usr/src/linux /somewhere + updatedb 

The overall performance is indeed better.... I was able to still move around
under all that load, only saw a peak in the LA of 1.45 and recovered nicely to
0.0.8(after cp and updatedb were done). 

Getting there : )

-- 
Bryan Paxton

"I don't need to sleep or eat, I'll smoke a thousand cigarettes."
- Sebadoh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

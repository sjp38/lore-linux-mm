Date: Thu, 2 Nov 2000 16:04:07 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#04, buffer wakeup fix
Message-ID: <20001102160407.G1876@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="reI/iBAAp9kzkmX4"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--reI/iBAAp9kzkmX4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Minor fix for kiobufs: add buffer_wait wakeups when we release
buffer_heads.

--Stephen

--reI/iBAAp9kzkmX4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="04-wakeup.diff"

diff -ru linux-2.4.0-test10.kio.03/fs/buffer.c linux-2.4.0-test10.kio.04/fs/buffer.c
--- linux-2.4.0-test10.kio.03/fs/buffer.c	Thu Nov  2 12:08:54 2000
+++ linux-2.4.0-test10.kio.04/fs/buffer.c	Thu Nov  2 14:13:08 2000
@@ -1923,6 +1923,7 @@
 	}
 	
 	spin_unlock(&unused_list_lock);
+	wake_up(&buffer_wait);
 
 	if (!iosize)
 		return -EIO;
@@ -2068,6 +2069,7 @@
 		__put_unused_buffer_head(bh[i]);
 	}
 	spin_unlock(&unused_list_lock);
+	wake_up(&buffer_wait);
 	goto finished;
 }
 

--reI/iBAAp9kzkmX4--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Message-ID: <3C0577FF.3040209@zytor.com>
Date: Wed, 28 Nov 2001 15:49:19 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Status of sendfile() + HIGHMEM
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

zeus.kernel.org is currently running with HIGHMEM turned off, since it
crashed due to an unfortunate interaction between sendfile() and HIGHMEM
-- this was using 2.4.10-ac4 or thereabouts.

The current zeus.kernel.org has 1 GB of RAM, however, it looks like we're
going to get a 6 GB machine donated.  Clearly HIGHMEM is going to be
necessary (still an x86 machine, unfortunately), and I wanted to ask if it
was believed that these problems had been worked out...

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

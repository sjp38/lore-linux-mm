Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id WAA13414
	for <linux-mm@kvack.org>; Tue, 28 Jan 2003 22:07:09 -0800 (PST)
Date: Tue, 28 Jan 2003 22:07:29 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Linus rollup
Message-Id: <20030128220729.1f61edfe.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>, Andi Kleen <ak@muc.de>, "David S. Miller" <davem@redhat.com>, David Mosberger <davidm@napali.hpl.hp.com>, Anton Blanchard <anton@samba.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Gents,

I've sifted out all the things which I intend to send to the boss soon.  It
would be good if you could perform some quick non-ia32 testing please.

Possible breakage would be in the new frlock-for-xtime_lock code and the
get_order() cleanup.

The frlock code is showing nice speedups, but I think the main reason we want
this is to fix the problem wherein an application spinning on gettimeofday()
can make time stop.

It's all at

http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-lt1/

Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Tue, 14 Dec 1999 01:55:54 -0800
Message-Id: <199912140955.BAA19455@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <199912140946.BAA07601@google.engr.sgi.com>
	(kanoj@google.engr.sgi.com)
Subject: Re: 2.3 Pagedir allocation/free and update races
References: <199912140946.BAA07601@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kanoj@google.engr.sgi.com
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   So, all architectures that cache page directories have racy code.

They are cpu local, how can they be racy?

If you are mentioning the kernel pgdir update cases, well even then
many architectures do not even need to update any of the pgtable
caches during such events (sparc64 for example).

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

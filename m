Date: Wed, 30 Oct 2002 10:06:01 -0800 (PST)
From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: printk long long
In-Reply-To: <Pine.LNX.4.33.0210292118330.1080-100000@wildwood.eecs.umich.edu>
Message-ID: <Pine.LNX.4.33L2.0210301005170.18828-100000@dragon.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hai Huang <haih@eecs.umich.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Oct 2002, Hai Huang wrote:

| As the title, I've tried couple different things to print a long
| long variable using printk (by %ll, %qd, ...) but without success.
| Anyone knows the right format?

%L

see linux/lib/vsprintf.c

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

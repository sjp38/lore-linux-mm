Date: Fri, 31 Jan 2003 00:51:42 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: New version of frlock (now called seqlock)
Message-ID: <20030130235142.GA32738@wotan.suse.de>
References: <1043969416.10155.619.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1043969416.10155.619.camel@dell_ss3.pdx.osdl.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Hemminger <shemminger@osdl.org>
Cc: Andrew Morton <akpm@digeo.com>, Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <ak@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I noticed that a lot of functions are called seq_* now.
But we already have a seq_* family - Al Viro's seq_files,
which also have lots of seq_* functions.
Perhaps it would be better to call it seqlock_* to avoid confusion.

Sorry for be annoying.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

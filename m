Subject: Re: New version of frlock (now called seqlock)
From: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030130235142.GA32738@wotan.suse.de>
References: <1043969416.10155.619.camel@dell_ss3.pdx.osdl.net>
	 <20030130235142.GA32738@wotan.suse.de>
Content-Type: text/plain
Message-Id: <1043973198.10153.633.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Date: 30 Jan 2003 16:33:19 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@digeo.com>, Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2003-01-30 at 15:51, Andi Kleen wrote:
> I noticed that a lot of functions are called seq_* now.
> But we already have a seq_* family - Al Viro's seq_files,
> which also have lots of seq_* functions.
> Perhaps it would be better to call it seqlock_* to avoid confusion.
> 
> Sorry for be annoying.

No problem:
 Name changes now are tedious, but easy.
 Name changes later are nasty and error prone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

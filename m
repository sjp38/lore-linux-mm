Message-ID: <3C0CA370.8D9E40F1@earthlink.net>
Date: Tue, 04 Dec 2001 10:20:32 +0000
From: Joseph A Knapka <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: runtimeimage of kernel module
References: <20011204085740.63317.qmail@web12001.mail.yahoo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anumula Venkat <anumulavenkat@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Anumula Venkat wrote:
> 
> Hello Friends,
> 
>     Can anybody tell me how runtime image of kernel
> module will be formed ?
>      I know that all kernel modules will run in one
> address space. And for user level applications stack
> will be formed at 0xbfff.. ( something of this kind ).
> 
> My doubt is where does the stack will be formed for
> kernel modules ?

All kernel code runs in the context of the process
that's running when kernel mode is entered. That
means module code will execute using the kernel stack
of the current process.

Cheers,

-- Joe
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

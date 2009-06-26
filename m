Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C46FA6B0098
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 18:45:05 -0400 (EDT)
Date: Sat, 27 Jun 2009 01:48:02 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak suggestion (long message)
Message-ID: <20090626224802.GB3858@localdomain.by>
References: <20090625221816.GA3480@localdomain.by>
 <20090626065923.GA14078@elte.hu>
 <84144f020906260007u3e79086bv91900e487ba0fb50@mail.gmail.com>
 <20090626081452.GB3451@localdomain.by>
 <1246004270.27533.16.camel@penberg-laptop>
 <20090626085056.GC3451@localdomain.by>
 <1246032766.30717.44.camel@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1246032766.30717.44.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (06/26/09 17:12), Catalin Marinas wrote:
> I had a look at your patch and I tend to agree with Pekka. It really
> adds too much complexity for something that could be easily done in user
> space (could be more concise or even written in perl, awk, sed, python
> etc.):
> 
> cat /sys/kernel/debug/kmemleak | tr "\n" "#" \
> 	| sed -e "s/#unreferenced/\nunreferenced/g" \
> 	| grep -v "tty_ldisc_try_get" | tr "#" "\n"
> 
Well, it's hardly can be compared with 
echo "block=ADDRESS_FROM_STACK" > /.../kmemleak

Frankly, I still found it useful (as you don't have to write in perl, awk, sed, python etc 
to see 50 lines (you are interested in) out of 1000.
You just watching reports.)

(well, maybe not as useful as with syslog.)
 
Anyway, the decision is yours. And let it be so.
Thanks.

> Thanks anyway.
> 
> -- 
> Catalin
> 

	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

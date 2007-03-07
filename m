Message-ID: <45EE42BC.6030209@debian.org>
Date: Tue, 06 Mar 2007 23:42:36 -0500
From: Andres Salomon <dilinger@debian.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: don't use ZONE_DMA unless CONFIG_ZONE_DMA is set
 in setup.c
References: <45EDFEDB.3000507@debian.org> <20070306175246.b1253ec3.akpm@linux-foundation.org> <20070307040248.GA30278@redhat.com>
In-Reply-To: <20070307040248.GA30278@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andres Salomon <dilinger@debian.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave Jones wrote:
> On Tue, Mar 06, 2007 at 05:52:46PM -0800, Andrew Morton wrote:
>  > On Tue, 06 Mar 2007 18:52:59 -0500
>  > Andres Salomon <dilinger@debian.org> wrote:
>  > 
>  > > If CONFIG_ZONE_DMA is ever undefined, ZONE_DMA will also not be defined,
>  > > and setup.c won't compile.  This wraps it with an #ifdef.
>  > > 
>  > 
>  > I guess if anyone tries to disable ZONE_DMA on i386 they'll pretty quickly
>  > discover that.  But I don't think we need to "fix" it yet?

Oh, it's certainly not urgent.  I sent it simply for correctness reasons.

It would've been nice to see the ZONE_DMA removal patches just #define
ZONE_DMA regardless, and include less #ifdefs scattered about; but at
this point, I'd just as soon prefer to see a proper way to allocate
things based on address constraints (as discussed in
http://www.gelato.unsw.edu.au/archives/linux-ia64/0609/19036.html).


> 
> CONFIG_ZONE_DMA isn't even optional on i386, so I'm curious how
> you could hit this compile failure.
> 

Why, with custom code of course ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: by zproxy.gmail.com with SMTP id k1so221369nzf
        for <linux-mm@kvack.org>; Thu, 06 Oct 2005 03:38:34 -0700 (PDT)
Message-ID: <aec7e5c30510060338o7865119bu995e31dfb4bd54ee@mail.gmail.com>
Date: Thu, 6 Oct 2005 19:38:33 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Reply-To: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH] i386: nid_zone_sizes_init() update
In-Reply-To: <1128528774.26009.12.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051005083515.4305.16399.sendpatchset@cherry.local>
	 <1128528774.26009.12.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 10/6/05, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Wed, 2005-10-05 at 17:35 +0900, Magnus Damm wrote:
> > Broken out nid_zone_sizes_init() change from i386 NUMA emulation code.
> ...
> > -static inline unsigned long  nid_size_pages(int nid)
> > -{
> > -     return node_end_pfn[nid] - node_start_pfn[nid];
> > -}
> > -static inline int nid_starts_in_highmem(int nid)
> > -{
> > -     return node_start_pfn[nid] >= max_low_pfn;
> > -}
>
> Hey, I liked those helpers!

Well, too bad for you! ;)

> When I suggested that you make your patches apply on top of the existing
> -mhp stuff, I didn't just mean that they should _apply_, they should
> probably mesh a little bit better.  For instance, it would be very
> helpful to use those 'static inlines', or make a couple new ones if you
> need them.

Okey, I think I understand. And I agree that more effort could be put
into this to make the code look better.  I thought this change was
required for the NUMA emulation code, but it turns out it wasn't. I
guess keeping the code as is and ignoring the patch is probably the
best solution.

Thanks!

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

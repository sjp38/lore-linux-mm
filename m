Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f52.google.com (mail-qe0-f52.google.com [209.85.128.52])
	by kanga.kvack.org (Postfix) with ESMTP id 07A996B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 10:21:20 -0500 (EST)
Received: by mail-qe0-f52.google.com with SMTP id ne12so1104069qeb.11
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 07:21:20 -0800 (PST)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id h17si2974980qej.41.2013.12.19.07.21.18
        for <linux-mm@kvack.org>;
        Thu, 19 Dec 2013 07:21:19 -0800 (PST)
Date: Thu, 19 Dec 2013 09:21:15 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 0/7] re-shrink 'struct page' when SLUB is on.
In-Reply-To: <52B2424F.7050406@sr71.net>
Message-ID: <alpine.DEB.2.10.1312190920340.4238@nuc>
References: <20131213235903.8236C539@viggo.jf.intel.com> <20131216160128.aa1f1eb8039f5eee578cf560@linux-foundation.org> <52AF9EB9.7080606@sr71.net> <0000014301223b3e-a73f3d59-8234-48f1-9888-9af32709a879-000000@email.amazonses.com> <52B23CAF.809@sr71.net>
 <20131218164109.5e169e258378fac44ec5212d@linux-foundation.org> <52B2424F.7050406@sr71.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Pekka Enberg <penberg@kernel.org>

On Wed, 18 Dec 2013, Dave Hansen wrote:

> On 12/18/2013 04:41 PM, Andrew Morton wrote:
> >> > Unless somebody can find some holes in this, I think we have no choice
> >> > but to unset the HAVE_ALIGNED_STRUCT_PAGE config option and revert using
> >> > the cmpxchg, at least for now.
> >
> > So your scary patch series which shrinks struct page while retaining
> > the cmpxchg_double() might reclaim most of this loss?
>
> That's what I'll test next, but I hope so.
>
> The config tweak is important because it shows a low-risk way to get a
> small 'struct page', plus get back some performance that we lost and
> evidently never noticed.  A distro that was nearing a release might want
> to go with this, for instance.

Ok then lets just drop the cmpxchg updates to the page struct. The
spinlock code is already in there so just removing the __CMPXCHG flag
related processing should do the trick.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

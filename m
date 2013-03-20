Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 5D7DF6B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 16:18:42 -0400 (EDT)
Date: Wed, 20 Mar 2013 21:18:33 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 1/3] mm, nobootmem: fix wrong usage of max_low_pfn
Message-ID: <20130320201833.GA26387@merkur.ravnborg.org>
References: <1363670161-9214-1-git-send-email-iamjoonsoo.kim@lge.com> <CAE9FiQWXYGdAp82HE8Jg=HYdxWa5nPC5g63E6rNNwYyAQ-B5tg@mail.gmail.com> <20130319062522.GG8858@lge.com> <20130319064247.GH8858@lge.com> <CAE9FiQV=NWCgbV=AT1W6Y5a0jH+tk5Oi6dSDZ2XQoPgCoYZ8Cg@mail.gmail.com> <20130319080721.GI8858@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130319080721.GI8858@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <liuj97@gmail.com>

On Tue, Mar 19, 2013 at 05:07:21PM +0900, Joonsoo Kim wrote:
> On Tue, Mar 19, 2013 at 12:35:45AM -0700, Yinghai Lu wrote:
> > Can you check why sparc do not need to change interface during converting
> > to use memblock to replace bootmem?
> 
> Sure.
> According to my understanding to sparc32 code(arch/sparc/mm/init_32.c),
> they already use max_low_pfn as the maximum PFN value,
> not as the number of pages.

I assume you already know...
sparc64 uses memblock, but sparc32 does not.
I looked at using memblock for sparc32 some time ago but got
distracted by other stuff.
I recall from back then that these ackward named variables confused me,
and some of my confusion was likely rooted in sparc32 using
max_low_pfn for something elase than others do.

I have no plans to look into adding memblock support for sparc32
right now. But may eventually do so when I get some spare time.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

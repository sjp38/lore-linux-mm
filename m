Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 5C1D86B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 04:07:02 -0400 (EDT)
Date: Tue, 19 Mar 2013 17:07:21 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] mm, nobootmem: fix wrong usage of max_low_pfn
Message-ID: <20130319080721.GI8858@lge.com>
References: <1363670161-9214-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CAE9FiQWXYGdAp82HE8Jg=HYdxWa5nPC5g63E6rNNwYyAQ-B5tg@mail.gmail.com>
 <20130319062522.GG8858@lge.com>
 <20130319064247.GH8858@lge.com>
 <CAE9FiQV=NWCgbV=AT1W6Y5a0jH+tk5Oi6dSDZ2XQoPgCoYZ8Cg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQV=NWCgbV=AT1W6Y5a0jH+tk5Oi6dSDZ2XQoPgCoYZ8Cg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <liuj97@gmail.com>

On Tue, Mar 19, 2013 at 12:35:45AM -0700, Yinghai Lu wrote:
> Can you check why sparc do not need to change interface during converting
> to use memblock to replace bootmem?

Sure.
According to my understanding to sparc32 code(arch/sparc/mm/init_32.c),
they already use max_low_pfn as the maximum PFN value,
not as the number of pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

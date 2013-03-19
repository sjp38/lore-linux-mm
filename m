Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 3DB6B6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 03:35:46 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id k10so192370iea.33
        for <linux-mm@kvack.org>; Tue, 19 Mar 2013 00:35:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130319064247.GH8858@lge.com>
References: <1363670161-9214-1-git-send-email-iamjoonsoo.kim@lge.com>
	<CAE9FiQWXYGdAp82HE8Jg=HYdxWa5nPC5g63E6rNNwYyAQ-B5tg@mail.gmail.com>
	<20130319062522.GG8858@lge.com>
	<20130319064247.GH8858@lge.com>
Date: Tue, 19 Mar 2013 00:35:45 -0700
Message-ID: <CAE9FiQV=NWCgbV=AT1W6Y5a0jH+tk5Oi6dSDZ2XQoPgCoYZ8Cg@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm, nobootmem: fix wrong usage of max_low_pfn
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: multipart/alternative; boundary=20cf307f365c4bacfe04d84227a8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <liuj97@gmail.com>

--20cf307f365c4bacfe04d84227a8
Content-Type: text/plain; charset=ISO-8859-1

Can you check why sparc do not need to change interface during converting
to use memblock to replace bootmem?

--20cf307f365c4bacfe04d84227a8
Content-Type: text/html; charset=ISO-8859-1

Can you check why sparc do not need to change interface during converting to use memblock to replace bootmem?<span></span>

--20cf307f365c4bacfe04d84227a8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

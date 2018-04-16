Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 617706B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:40:48 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k27so12507415wre.23
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 05:40:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5si592932eda.293.2018.04.16.05.40.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 05:40:47 -0700 (PDT)
Subject: Re: slab: introduce the flag SLAB_MINIMIZE_WASTE
References: <20180320173512.GA19669@bombadil.infradead.org>
 <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake>
 <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake>
 <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake>
 <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com>
 <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz>
 <20180413151019.GA5660@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz>
Date: Mon, 16 Apr 2018 14:38:49 +0200
MIME-Version: 1.0
In-Reply-To: <20180413151019.GA5660@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/13/2018 05:10 PM, Mike Snitzer wrote:
> On Fri, Apr 13 2018 at  5:22am -0400,
> Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>> Would this perhaps be a good LSF/MM discussion topic? Mikulas, are you
>> attending, or anyone else that can vouch for your usecase?
> 
> Any further discussion on SLAB_MINIMIZE_WASTE should continue on list.
> 
> Mikulas won't be at LSF/MM.  But I included Mikulas' dm-bufio changes
> that no longer depend on this proposed SLAB_MINIMIZE_WASTE (as part of
> the 4.17 merge window).

Can you or Mikulas briefly summarize how the dependency is avoided, and
whether if (something like) SLAB_MINIMIZE_WASTE were implemented, the
dm-bufio code would happily switch to it, or not?

Thanks,
Vlastimil

> Mike
> 

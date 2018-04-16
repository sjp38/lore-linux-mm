Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 970F66B0009
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 17:04:13 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w17so11181319qkb.19
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:04:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z63si6952098qkz.347.2018.04.16.14.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 14:04:12 -0700 (PDT)
Date: Mon, 16 Apr 2018 17:04:12 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz>
Message-ID: <alpine.LRH.2.02.1804161703171.7237@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180320173512.GA19669@bombadil.infradead.org> <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake>
 <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz> <20180413151019.GA5660@redhat.com> <ee8807ff-d650-0064-70bf-e1d77fa61f5c@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Snitzer <snitzer@redhat.com>, Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>



On Mon, 16 Apr 2018, Vlastimil Babka wrote:

> On 04/13/2018 05:10 PM, Mike Snitzer wrote:
> > On Fri, Apr 13 2018 at  5:22am -0400,
> > Vlastimil Babka <vbabka@suse.cz> wrote:
> >>
> >> Would this perhaps be a good LSF/MM discussion topic? Mikulas, are you
> >> attending, or anyone else that can vouch for your usecase?
> > 
> > Any further discussion on SLAB_MINIMIZE_WASTE should continue on list.
> > 
> > Mikulas won't be at LSF/MM.  But I included Mikulas' dm-bufio changes
> > that no longer depend on this proposed SLAB_MINIMIZE_WASTE (as part of
> > the 4.17 merge window).
> 
> Can you or Mikulas briefly summarize how the dependency is avoided, and

This was Mike's misconception - dm-bufio actually needs the 
SLAB_MINIMIZE_WASTE patch, otherwise it is wasting memory.

> whether if (something like) SLAB_MINIMIZE_WASTE were implemented, the
> dm-bufio code would happily switch to it, or not?
> 
> Thanks,
> Vlastimil

Mikulas

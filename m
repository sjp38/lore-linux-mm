Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 85B316B0003
	for <linux-mm@kvack.org>; Sun, 10 Jun 2018 19:33:04 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 5-v6so18269265qke.19
        for <linux-mm@kvack.org>; Sun, 10 Jun 2018 16:33:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c12-v6si399622qkb.288.2018.06.10.16.33.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jun 2018 16:33:03 -0700 (PDT)
Date: Mon, 11 Jun 2018 07:32:56 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v4 3/4] mm/sparse: Add a new parameter 'data_unit_size'
 for alloc_usemap_and_memmap
Message-ID: <20180610233256.GF16231@MiWiFi-R3L-srv>
References: <20180521101555.25610-1-bhe@redhat.com>
 <20180521101555.25610-4-bhe@redhat.com>
 <8ff7638c-d3ee-a40c-e5cf-deded8d19e93@intel.com>
 <20180608062733.GB16231@MiWiFi-R3L-srv>
 <74359df3-76a8-6dc7-51c5-27019130224f@intel.com>
 <20180608151748.GE16231@MiWiFi-R3L-srv>
 <6cb5f16f-68a6-84af-c7e6-1a563133fac8@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6cb5f16f-68a6-84af-c7e6-1a563133fac8@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 06/08/18 at 09:13am, Dave Hansen wrote:
> On 06/08/2018 08:17 AM, Baoquan He wrote:
> > 
> > Then inside alloc_usemap_and_memmap(), For each node, we get how many
> > present sections on this node, call hook alloc_func(). Then we update
> > the pointer to point at a new position of usemap_map[] or map_map[].
> 
> I think this is the key.
> 
> alloc_usemap_and_memmap() is passed in a "void *" that it needs to
> update as things get consumed.  But, it knows only the quantity of
> objects consumed and not the type.  This effectively tells it enough
> about the type to let it update the pointer as objects are consumed.
> 
> Right?
> 
> Can we get that in the changelog?

Hmm, I like above sentences very much, thanks.

Do you means putting it in changelog, but not commit log of patch 3/4,
right? I can do this when repost.

Thanks
Baoquan

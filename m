Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4AF056B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 12:13:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d20-v6so6415456pfn.16
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 09:13:56 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d13-v6si16384026pfe.214.2018.06.08.09.13.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 09:13:55 -0700 (PDT)
Subject: Re: [PATCH v4 3/4] mm/sparse: Add a new parameter 'data_unit_size'
 for alloc_usemap_and_memmap
References: <20180521101555.25610-1-bhe@redhat.com>
 <20180521101555.25610-4-bhe@redhat.com>
 <8ff7638c-d3ee-a40c-e5cf-deded8d19e93@intel.com>
 <20180608062733.GB16231@MiWiFi-R3L-srv>
 <74359df3-76a8-6dc7-51c5-27019130224f@intel.com>
 <20180608151748.GE16231@MiWiFi-R3L-srv>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <6cb5f16f-68a6-84af-c7e6-1a563133fac8@intel.com>
Date: Fri, 8 Jun 2018 09:13:54 -0700
MIME-Version: 1.0
In-Reply-To: <20180608151748.GE16231@MiWiFi-R3L-srv>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 06/08/2018 08:17 AM, Baoquan He wrote:
> 
> Then inside alloc_usemap_and_memmap(), For each node, we get how many
> present sections on this node, call hook alloc_func(). Then we update
> the pointer to point at a new position of usemap_map[] or map_map[].

I think this is the key.

alloc_usemap_and_memmap() is passed in a "void *" that it needs to
update as things get consumed.  But, it knows only the quantity of
objects consumed and not the type.  This effectively tells it enough
about the type to let it update the pointer as objects are consumed.

Right?

Can we get that in the changelog?

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 932F36B000A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 13:52:31 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e1-v6so5345405pld.23
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 10:52:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b15-v6si9860385pfc.320.2018.06.29.10.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 10:52:30 -0700 (PDT)
Subject: Re: [PATCH v5 4/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
References: <20180627013116.12411-1-bhe@redhat.com>
 <20180627013116.12411-5-bhe@redhat.com>
 <cb67381c-078c-62e6-e4c0-9ecf3de9e84d@intel.com>
 <CAGM2rebsL_fS8XKRvN34NWiFN3Hh63ZOD8jDj8qeSOUPXcZ2fA@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <88f16247-aea2-f429-600e-4b54555eb736@intel.com>
Date: Fri, 29 Jun 2018 10:52:28 -0700
MIME-Version: 1.0
In-Reply-To: <CAGM2rebsL_fS8XKRvN34NWiFN3Hh63ZOD8jDj8qeSOUPXcZ2fA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: bhe@redhat.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

On 06/29/2018 10:48 AM, Pavel Tatashin wrote:
> Here is example:
> Node1:
> map_map[0] -> Struct pages ...
> map_map[1] -> NULL
> Node2:
> map_map[2] -> Struct pages ...
> 
> We always want to configure section from Node2 with struct pages from
> Node2. Even, if there are holes in-between. The same with usemap.

Right...  But your example consumes two mem_map[]s.

But, from scanning the code, we increment nr_consumed_maps three times.
Correct?

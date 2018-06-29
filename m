Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA1C76B0007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:57:05 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id x6-v6so4284942pgp.9
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:57:05 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id f15-v6si4197929pgt.37.2018.06.29.11.57.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 11:57:04 -0700 (PDT)
Subject: Re: [PATCH v5 4/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
References: <20180627013116.12411-1-bhe@redhat.com>
 <20180627013116.12411-5-bhe@redhat.com>
 <cb67381c-078c-62e6-e4c0-9ecf3de9e84d@intel.com>
 <CAGM2rebsL_fS8XKRvN34NWiFN3Hh63ZOD8jDj8qeSOUPXcZ2fA@mail.gmail.com>
 <88f16247-aea2-f429-600e-4b54555eb736@intel.com>
 <b8d5b9cb-ca09-4bcc-0a31-3db1232fe787@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7ad120fb-377b-6963-62cb-a1a5eaa6cad4@intel.com>
Date: Fri, 29 Jun 2018 11:56:48 -0700
MIME-Version: 1.0
In-Reply-To: <b8d5b9cb-ca09-4bcc-0a31-3db1232fe787@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: bhe@redhat.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

On 06/29/2018 11:01 AM, Pavel Tatashin wrote:
> Correct: it should be incremented on every iteration of the loop. No matter if the entries contained valid data or NULLs. So we increment in three places:
> 
> if map_map[] has invalid entry, increment, continue
> if usemap_map[] has invalid entry, increment, continue
> at the end of the loop, everything was valid we increment it
> 
> This is done so nr_consumed_maps does not get out of sync with the
> current pnum. pnum does not equal to nr_consumed_maps, as there are
> may be holes in pnums, but there is one-to-one correlation.
Can this be made more clear in the code?

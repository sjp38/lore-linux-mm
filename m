Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C47C6B0005
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 10:05:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d4-v6so2817268pfn.9
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 07:05:21 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q65-v6si2296008pga.283.2018.06.28.07.05.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 07:05:19 -0700 (PDT)
Subject: Re: [PATCH v6 4/5] mm/sparse: Optimize memmap allocation during
 sparse_init()
References: <20180628062857.29658-1-bhe@redhat.com>
 <20180628062857.29658-5-bhe@redhat.com>
 <20180628120937.GC12956@techadventures.net>
 <CAGM2reZsZVhhg2=dQZf6D-NmPTFRN-_95+s61pC7Axz5G5mkMQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <3e014554-abf9-8a18-e890-be43d48d5eb0@intel.com>
Date: Thu, 28 Jun 2018 07:05:17 -0700
MIME-Version: 1.0
In-Reply-To: <CAGM2reZsZVhhg2=dQZf6D-NmPTFRN-_95+s61pC7Axz5G5mkMQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, osalvador@techadventures.net
Cc: bhe@redhat.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

On 06/28/2018 05:12 AM, Pavel Tatashin wrote:
> You did not, this is basically a safety check. A BUG_ON() would be
> better here. As, this something that should really not happening, and
> would mean a bug in the current project.

Is this at a point in boot where a BUG_ON() generally produces useful
output, or will it just produce and early-boot silent hang with no
console output?

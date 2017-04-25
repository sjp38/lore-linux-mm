Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD9E86B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 03:08:47 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j29so46328423qtj.19
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 00:08:47 -0700 (PDT)
Received: from edison.jonmasters.org (edison.jonmasters.org. [173.255.233.168])
        by mx.google.com with ESMTPS id e126si21051469qkb.62.2017.04.25.00.08.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Apr 2017 00:08:47 -0700 (PDT)
References: <20170422033037.3028-1-jglisse@redhat.com>
 <20170422033037.3028-4-jglisse@redhat.com>
 <CAPcyv4jq0+FptsqUY14PA7WfgjYOt-kA5r084c8vvmkAU8WqaQ@mail.gmail.com>
 <20170422181151.GA2360@redhat.com>
 <CAPcyv4jr=CNuaGQt80SwR5dpiXy_pDr8aD-w0EtLNE4oGC8WcQ@mail.gmail.com>
 <f88de491-1cd2-75e1-4304-dc11c96b5d2a@nvidia.com>
From: Jon Masters <jcm@jonmasters.org>
Message-ID: <b94c74b6-14a1-a537-ada2-ee98bdafb255@jonmasters.org>
Date: Tue, 25 Apr 2017 03:08:43 -0400
MIME-Version: 1.0
In-Reply-To: <f88de491-1cd2-75e1-4304-dc11c96b5d2a@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Subject: Re: [HMM 03/15] mm/unaddressable-memory: new type of ZONE_DEVICE for
 unaddressable memory
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 04/23/2017 08:39 PM, John Hubbard wrote:

> Actually, MEMORY_DEVICE_PRIVATE / _PUBLIC seems like a good choice to 
> me, because the memory may not remain CPU-unaddressable in the future. 
> By that, I mean that I know of at least one company (ours) that is 
> working on products that will support hardware-based memory coherence 
> (and access counters to go along with that). If someone were to enable 
> HMM on such a system, then the device memory would be, in fact, directly 
> addressable by a CPU--thus exactly contradicting the "unaddressable" name.

I'm expecting similar with CCIX-like coherently attached accelerators
running within FPGAs and as discrete devices as well. Everyone and their
dog is working on hardware based coherence as a programming convenience
and so the notion of ZONE_DEVICE as it stood is going to rapidly evolve
over the next 18 months, maybe less. Short term anyway.

Jon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

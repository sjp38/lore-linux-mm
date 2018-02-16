Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 776786B0006
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 16:08:14 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id n11so2956311plp.13
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:08:14 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id a33-v6si220752pld.653.2018.02.16.13.08.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 13:08:13 -0800 (PST)
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
 <87d2edf7-ce5e-c643-f972-1f2538208d86@intel.com>
 <alpine.DEB.2.20.1802161413340.11934@nuc-kabylake>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <7fcd53ab-ba06-f80e-6cb7-73e87bcbdd20@intel.com>
Date: Fri, 16 Feb 2018 13:08:11 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1802161413340.11934@nuc-kabylake>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mel Gorman <mel@skynet.ie>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Mike Kravetz <mike.kravetz@oracle.com>

On 02/16/2018 12:15 PM, Christopher Lameter wrote:
>> This has the potential to be really confusing to apps.  If this memory
>> is now not available to normal apps, they might plow into the invisible
>> memory limits and get into nasty reclaim scenarios.
>> Shouldn't this subtract the memory for MemFree and friends?
> Ok certainly we could do that. But on the other hand the memory is
> available if those subsystems ask for the right order. Its not clear to me
> what the right way of handling this is. Right now it adds the reserved
> pages to the watermarks. But then under some circumstances the memory is
> available. What is the best solution here?

There's definitely no perfect solution.

But, in general, I think we should cater to the dumbest users.  Folks
doing higher-order allocations are not that.  I say we make the picture
the most clear for the traditional 4k users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

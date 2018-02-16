Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7516B0007
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 16:47:58 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 189so2861235pge.0
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:47:58 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id x6si5638721pgc.357.2018.02.16.13.47.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 13:47:57 -0800 (PST)
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
 <87d2edf7-ce5e-c643-f972-1f2538208d86@intel.com>
 <alpine.DEB.2.20.1802161413340.11934@nuc-kabylake>
 <7fcd53ab-ba06-f80e-6cb7-73e87bcbdd20@intel.com>
 <20180216214353.GA32655@bombadil.infradead.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <4925b480-f6ef-1a7a-66ac-75c8ec9d9d58@intel.com>
Date: Fri, 16 Feb 2018 13:47:55 -0800
MIME-Version: 1.0
In-Reply-To: <20180216214353.GA32655@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Mike Kravetz <mike.kravetz@oracle.com>

On 02/16/2018 01:43 PM, Matthew Wilcox wrote:
>> There's definitely no perfect solution.
>>
>> But, in general, I think we should cater to the dumbest users.  Folks
>> doing higher-order allocations are not that.  I say we make the picture
>> the most clear for the traditional 4k users.
> Your way might be confusing -- if there's a system which is under varying
> amounts of jumboframe load and all the 16k pages get gobbled up by the
> ethernet driver, MemFree won't change at all, for example.

IOW, you agree that "there's definitely no perfect solution." :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

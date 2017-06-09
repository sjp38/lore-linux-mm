Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EAA206B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 12:59:52 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t126so27887884pgc.9
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 09:59:52 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a15si1306852plt.308.2017.06.09.09.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 09:59:52 -0700 (PDT)
Subject: Re: [RFC v4 00/20] Speculative page faults
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170609150126.GI21764@dhcp22.suse.cz>
 <83cf1566-3e76-d3fa-10a8-d83bbf9fd568@linux.vnet.ibm.com>
 <20170609163520.GB9332@dhcp22.suse.cz>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <84e1698a-c85f-ee10-d367-2c203c6eea73@linux.intel.com>
Date: Fri, 9 Jun 2017 09:59:50 -0700
MIME-Version: 1.0
In-Reply-To: <20170609163520.GB9332@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

On 06/09/2017 09:35 AM, Michal Hocko wrote:
> On Fri 09-06-17 17:25:51, Laurent Dufour wrote:
> [...]
>> Thanks Michal for your feedback.
>>
>> I mostly focused on this database workload since this is the one where
>> we hit the mmap_sem bottleneck when running on big node. On my usual
>> victim node, I checked for basic usage like kernel build time, but I
>> agree that's clearly not enough.
>>
>> I try to find details about the 'kbench' you mentioned, but I didn't get
>> any valid entry.
>> Would you please point me on this or any other bench tool you think will
>> be useful here ?
> 
> Sorry I meant kernbech (aka parallel kernel build). Other highly threaded
> workloads doing a lot of page faults and address space modification
> would be good to see as well. I wish I could give you much more
> comprehensive list but I am not very good at benchmarks.
> 

Laurent,

Have you tried running the multi-fault microbenchmark by Kamezawa?
It does threaded page faults in parallel.
Peter ran that when he posted his specualtive page faults patches.
https://lkml.org/lkml/2010/1/6/28

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

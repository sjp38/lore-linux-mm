Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3818F6B000A
	for <linux-mm@kvack.org>; Mon,  7 May 2018 21:14:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d4-v6so20706486wrn.15
        for <linux-mm@kvack.org>; Mon, 07 May 2018 18:14:08 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id d20-v6si2539574edp.183.2018.05.07.18.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 18:14:07 -0700 (PDT)
Reply-To: prakash.sangappa@oracle.com
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
 <20180502143323.1c723ccb509c3497050a2e0a@linux-foundation.org>
 <2ce01d91-5fba-b1b7-2956-c8cc1853536d@intel.com>
 <33f96879-351f-674a-ca23-43f233f4eb1d@linux.vnet.ibm.com>
 <82d2b35c-272a-ad02-692f-2c109aacdfb6@oracle.com>
 <8569dabb-4930-aa20-6249-72457e2df51e@intel.com>
 <51145ccb-fc0d-0281-9757-fb8a5112ec24@oracle.com>
 <c72fea44-59f3-b106-8311-b5eae2d254e7@intel.com>
From: "prakash.sangappa" <prakash.sangappa@oracle.com>
Message-ID: <addeaadc-5ab2-f0c9-2194-dd100ae90f3a@oracle.com>
Date: Mon, 7 May 2018 18:16:13 -0700
MIME-Version: 1.0
In-Reply-To: <c72fea44-59f3-b106-8311-b5eae2d254e7@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com, Naoya Horiguchi <nao.horiguchi@gmail.com>



On 05/07/2018 05:05 PM, Dave Hansen wrote:
> On 05/07/2018 04:22 PM, prakash.sangappa wrote:
>> However, with the proposed new file, we could allow seeking to
>> specified virtual address. The lseek offset in this case would
>> represent the virtual address of the process. Subsequent read from
>> the file would provide VA range to numa node information starting
>> from that VA. In case the VA seek'ed to is invalid, it will start
>> from the next valid mapped VA of the process. The implementation
>> would not be based on seq_file.
> So you're proposing a new /proc/<pid> file that appears next to and is
> named very similarly to the exiting /proc/<pid>, but which has entirely
> different behavior?

It will be /proc/<pid>/numa_vamaps. Yes, the behavior will be
different with respect to seeking. Output will still be text and
the format will be same.

I want to get feedback on this approach.

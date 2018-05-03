Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4922F6B0010
	for <linux-mm@kvack.org>; Thu,  3 May 2018 18:26:55 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z5so4556402pfz.6
        for <linux-mm@kvack.org>; Thu, 03 May 2018 15:26:55 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id e7-v6si14440311plk.397.2018.05.03.15.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 15:26:54 -0700 (PDT)
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
 <20180502143323.1c723ccb509c3497050a2e0a@linux-foundation.org>
 <2ce01d91-5fba-b1b7-2956-c8cc1853536d@intel.com>
 <33f96879-351f-674a-ca23-43f233f4eb1d@linux.vnet.ibm.com>
 <82d2b35c-272a-ad02-692f-2c109aacdfb6@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <8569dabb-4930-aa20-6249-72457e2df51e@intel.com>
Date: Thu, 3 May 2018 15:26:53 -0700
MIME-Version: 1.0
In-Reply-To: <82d2b35c-272a-ad02-692f-2c109aacdfb6@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: prakash.sangappa@oracle.com, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 05/03/2018 03:27 PM, prakash.sangappa wrote:
>>
> If each consecutive page comes from different node, yes in
> the extreme case is this file will have a lot of lines. All the lines
> are generated at the time file is read. The amount of data read will be
> limited to the user read buffer size used in the read.
> 
> /proc/<pid>/pagemap also has kind of  similar issue. There is 1 64
> bit value for each user page.
But nobody reads it sequentially.  Everybody lseek()s because it has a
fixed block size.  You can't do that in text.

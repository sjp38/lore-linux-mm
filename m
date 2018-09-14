Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 215A28E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 15:03:26 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p22-v6so5048452pfj.7
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 12:03:26 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id z2-v6si7708396pgn.494.2018.09.14.12.03.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 12:03:24 -0700 (PDT)
Subject: Re: [PATCH V2 0/6] VA to numa node information
References: <1536783844-4145-1-git-send-email-prakash.sangappa@oracle.com>
 <20180913084011.GC20287@dhcp22.suse.cz>
 <375951d0-f103-dec3-34d8-bbeb2f45f666@oracle.com>
 <20180914055637.GH20287@dhcp22.suse.cz>
 <91988f05-2723-3120-5607-40fabe4a170d@oracle.com>
 <a26a71cb-101b-e7a2-9a2f-78995538dbca@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <9315ac49-e797-567b-3bb1-36831a524eb6@intel.com>
Date: Fri, 14 Sep 2018 12:01:10 -0700
MIME-Version: 1.0
In-Reply-To: <a26a71cb-101b-e7a2-9a2f-78995538dbca@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prakash Sangappa <prakash.sangappa@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, nao.horiguchi@gmail.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khandual@linux.vnet.ibm.com

On 09/14/2018 11:04 AM, Prakash Sangappa wrote:
> Also, for valid VMAs in  'maps' file, if the VMA is sparsely
> populated with  physical pages, the page walk can skip over non
> existing page table entires (PMDs) and so can be faster.
Note that this only works for things that were _never_ populated.  They
might be sparse after once being populated and then being reclaimed or
discarded.  Those will still have all the page tables allocated.

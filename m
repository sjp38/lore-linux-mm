Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE576B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 12:19:58 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d123so208184064pfd.0
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 09:19:58 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id p61si13114406plb.300.2017.01.30.09.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 09:19:56 -0800 (PST)
Subject: Re: [RFC V2 02/12] mm: Isolate HugeTLB allocations away from CDM
 nodes
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-3-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <01671749-c649-e015-4f51-7acaa1fb5b80@intel.com>
Date: Mon, 30 Jan 2017 09:19:56 -0800
MIME-Version: 1.0
In-Reply-To: <20170130033602.12275-3-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/29/2017 07:35 PM, Anshuman Khandual wrote:
> HugeTLB allocation/release/accounting currently spans across all the nodes
> under N_MEMORY node mask. Coherent memory nodes should not be part of these
> allocations. So use system_ram() call to fetch system RAM only nodes on the
> platform which can then be used for HugeTLB allocation purpose instead of
> N_MEMORY node mask. This isolates coherent device memory nodes from HugeTLB
> allocations.

Does this end up making it impossible to use hugetlbfs to access device
memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

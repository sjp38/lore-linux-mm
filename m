Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 10D5E6B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 12:36:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 194so462363529pgd.7
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 09:36:22 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id r69si13215114pfk.242.2017.01.30.09.36.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 09:36:21 -0800 (PST)
Subject: Re: [RFC V2 05/12] cpuset: Add cpuset_inc() inside cpuset_init()
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-6-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <c0f9a927-2620-dea7-8038-bc1bc78107a4@intel.com>
Date: Mon, 30 Jan 2017 09:36:20 -0800
MIME-Version: 1.0
In-Reply-To: <20170130033602.12275-6-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/29/2017 07:35 PM, Anshuman Khandual wrote:
> Currently cpusets_enabled() wrongfully returns 0 even if we have a root
> cpuset configured on the system. This got missed when jump level was
> introduced in place of number_of_cpusets with the commit 664eeddeef65
> ("mm: page_alloc: use jump labels to avoid checking number_of_cpusets")
> . This fixes the problem so that cpusets_enabled() returns positive even
> for the root cpuset.
> 
> Fixes: 664eeddeef65 ("mm: page_alloc: use jump labels to avoid")
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

This needs to go upstream separately, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

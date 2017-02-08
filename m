Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F251B28089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 11:42:35 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 204so201604569pge.5
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 08:42:35 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id o2si7494568pga.229.2017.02.08.08.42.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 08:42:35 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id v184so15607996pgv.1
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 08:42:35 -0800 (PST)
Subject: Re: [PATCH 0/3] Define coherent device memory node
References: <20170208140148.16049-1-khandual@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <6ce19e4e-34ed-69c9-186d-03035d966ae1@gmail.com>
Date: Wed, 8 Feb 2017 22:12:24 +0530
MIME-Version: 1.0
In-Reply-To: <20170208140148.16049-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com



On 02/08/2017 07:31 PM, Anshuman Khandual wrote:
> 	This three patches define CDM node with HugeTLB & Buddy allocation
> isolation. Please refer to the last RFC posting mentioned here for details.
> The series has been split for easier review process. The next part of the
> work like VM flags, auto NUMA and KSM interactions with tagged VMAs will
> follow later.
>
> https://lkml.org/lkml/2017/1/29/198
>
> Optional Buddy allocation isolation methods
>
> (1) GFP flag based		(mm_cdm_v1_optional_gfp)
> (2) Zonelist rebuilding		(mm_cdm_v1_optional_zonelist)
> (3) Cpuset			(mm_cdm_v1_optional_cpusets)
>
> All of these optional methods as well as the posted nodemask (mm_cdm_v1)
> approach can be accessed from the following git tree.
>

Definitely much better looking, in general I like the approach and
would ack it. Lets stick to mm_cdm_v1 (this post) as a starting point

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

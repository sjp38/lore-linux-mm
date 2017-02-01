Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB19D6B0038
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 14:01:38 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y143so570256328pfb.6
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 11:01:38 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d1si19940599pli.33.2017.02.01.11.01.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 11:01:37 -0800 (PST)
Subject: Re: [RFC V2 02/12] mm: Isolate HugeTLB allocations away from CDM
 nodes
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-3-khandual@linux.vnet.ibm.com>
 <01671749-c649-e015-4f51-7acaa1fb5b80@intel.com>
 <be8665a1-43d2-436a-90df-b644365a2fc5@linux.vnet.ibm.com>
 <db9e7345-da08-5011-22ae-b20927b174f4@intel.com>
 <d1995ee9-246f-5920-8a75-61868c2a209e@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0f7b1e14-536f-0f2f-5345-90b5bb597a84@intel.com>
Date: Wed, 1 Feb 2017 11:01:35 -0800
MIME-Version: 1.0
In-Reply-To: <d1995ee9-246f-5920-8a75-61868c2a209e@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 02/01/2017 05:59 AM, Anshuman Khandual wrote:
> So shall we write all these details in the comment section for each
> patch after the SOB statement to be more visible ? Or some where
> in-code documentation as FIXME or XXX or something. These are little
> large paragraphs, hence was wondering.

I would make an effort to convey a maximum amount of content in a
minimal amount of words. :)

But, yeah, it is pretty obvious that you've got too much in the cover
letter and not enough in the patches descriptions.

...
> * Page faults (which will probably use __GFP_THISNODE) cannot come from the
>   CDM nodes as they dont have any CPUs.

Page faults happen on CPUs but they happen on VMAs that could be bound
to a CDM node.  We allocate based on the VMA policy first, the fall back
to the default policy which is based on the CPU doing the fault if the
VMA doesn't have a specific policy.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

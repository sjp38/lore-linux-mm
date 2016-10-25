Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2648F6B0260
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 08:36:56 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id t192so10440472ywf.4
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 05:36:56 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id n128si1242548itg.92.2016.10.25.05.36.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 05:36:55 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id i85so19533679pfa.0
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 05:36:55 -0700 (PDT)
Subject: Re: [RFC 5/8] mm: Add new flag VM_CDM for coherent device memory
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-6-git-send-email-khandual@linux.vnet.ibm.com>
 <580E4704.1040104@intel.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <2a9819b8-0d2d-fb2a-e9d1-094f7f3cf54c@gmail.com>
Date: Tue, 25 Oct 2016 23:36:34 +1100
MIME-Version: 1.0
In-Reply-To: <580E4704.1040104@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com



On 25/10/16 04:38, Dave Hansen wrote:
> On 10/23/2016 09:31 PM, Anshuman Khandual wrote:
>> VMAs containing coherent device memory should be marked with VM_CDM. These
>> VMAs need to be identified in various core kernel paths and this new flag
>> will help in this regard.
> 
> ... and it's sticky?  So if a VMA *ever* has one of these funky pages in
> it, it's stuck being VM_CDM forever?  Never to be merged with other
> VMAs?  Never to see the light of autonuma ever again?
> 
> What if a 100TB VMA has one page of fancy pants device memory, and the
> rest normal vanilla memory?  Do we really want to consider the whole
> thing fancy?
> 

Those are good review comments to improve the patchset.

> This whole patch set is looking really hackish.  If you want things to
> be isolated from the VM, them it should probably *actually* be isolated
> from the VM.  As Jerome mentioned, ZONE_DEVICE is probably a better
> thing to use here than to try what you're attempting.
> 

The RFC explains the motivation, this is not fancy pants, it is regular
memory from the systems perspective, with some changes as described

Thanks for the review!
Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

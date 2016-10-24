Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE8496B0260
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 13:38:14 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id tz10so17163741pab.3
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:38:14 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id r86si16399666pfk.297.2016.10.24.10.38.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 10:38:14 -0700 (PDT)
Subject: Re: [RFC 5/8] mm: Add new flag VM_CDM for coherent device memory
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-6-git-send-email-khandual@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <580E4704.1040104@intel.com>
Date: Mon, 24 Oct 2016 10:38:12 -0700
MIME-Version: 1.0
In-Reply-To: <1477283517-2504-6-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

On 10/23/2016 09:31 PM, Anshuman Khandual wrote:
> VMAs containing coherent device memory should be marked with VM_CDM. These
> VMAs need to be identified in various core kernel paths and this new flag
> will help in this regard.

... and it's sticky?  So if a VMA *ever* has one of these funky pages in
it, it's stuck being VM_CDM forever?  Never to be merged with other
VMAs?  Never to see the light of autonuma ever again?

What if a 100TB VMA has one page of fancy pants device memory, and the
rest normal vanilla memory?  Do we really want to consider the whole
thing fancy?

This whole patch set is looking really hackish.  If you want things to
be isolated from the VM, them it should probably *actually* be isolated
from the VM.  As Jerome mentioned, ZONE_DEVICE is probably a better
thing to use here than to try what you're attempting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

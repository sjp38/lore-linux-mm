Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F7866B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:00:34 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id yx5so2415913pac.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:00:34 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id l78si16552857pfi.288.2016.10.24.11.00.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:00:33 -0700 (PDT)
Subject: Re: [RFC 5/8] mm: Add new flag VM_CDM for coherent device memory
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-6-git-send-email-khandual@linux.vnet.ibm.com>
 <580E4704.1040104@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <580E4C40.50107@intel.com>
Date: Mon, 24 Oct 2016 11:00:32 -0700
MIME-Version: 1.0
In-Reply-To: <580E4704.1040104@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

On 10/24/2016 10:38 AM, Dave Hansen wrote:
> On 10/23/2016 09:31 PM, Anshuman Khandual wrote:
>> > VMAs containing coherent device memory should be marked with VM_CDM. These
>> > VMAs need to be identified in various core kernel paths and this new flag
>> > will help in this regard.
> ... and it's sticky?  So if a VMA *ever* has one of these funky pages in
> it, it's stuck being VM_CDM forever?  Never to be merged with other
> VMAs?  Never to see the light of autonuma ever again?

Urg, this is even worse than I suspected.

Does this handle shared pages (like the page cache mode you call out as
a requirement) where the "cdm" page is faulted into one process VMA, but
it was allocated against another?

Can't that give you a "cdm" page mapped into a non-VM_CDM VMA?  Or, a
VM_CDM VMA with no "cdm" pages in it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

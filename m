Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 08CA16B0035
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 21:32:22 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so1745545pde.24
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 18:32:21 -0700 (PDT)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id sp2si1868808pab.368.2014.04.08.18.32.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 18:32:20 -0700 (PDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Wed, 9 Apr 2014 11:32:16 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id B41D5357806E
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 11:32:13 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s391VxRk11927928
	for <linux-mm@kvack.org>; Wed, 9 Apr 2014 11:31:59 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s391WCoN004195
	for <linux-mm@kvack.org>; Wed, 9 Apr 2014 11:32:12 +1000
Message-ID: <5344A312.80802@linux.vnet.ibm.com>
Date: Wed, 09 Apr 2014 07:02:02 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/2] mm: move FAULT_AROUND_ORDER to arch/
References: <1396592835-24767-1-git-send-email-maddy@linux.vnet.ibm.com> <1396592835-24767-2-git-send-email-maddy@linux.vnet.ibm.com> <533EDB63.8090909@intel.com>
In-Reply-To: <533EDB63.8090909@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org

On Friday 04 April 2014 09:48 PM, Dave Hansen wrote:
> On 04/03/2014 11:27 PM, Madhavan Srinivasan wrote:
>> This patch creates infrastructure to move the FAULT_AROUND_ORDER
>> to arch/ using Kconfig. This will enable architecture maintainers
>> to decide on suitable FAULT_AROUND_ORDER value based on
>> performance data for that architecture. Patch also adds
>> FAULT_AROUND_ORDER Kconfig element in arch/X86.
> 
> Please don't do it this way.
> 
> In mm/Kconfig, put
> 
> 	config FAULT_AROUND_ORDER
> 		int
> 		default 1234 if POWERPC
> 		default 4
> 
> The way you have it now, every single architecture that needs to enable
> this has to go put that in their Kconfig.  That's madness.  This way,

I though about it and decided not to do this way because, in future,
sub platforms of the architecture may decide to change the values. Also,
adding an if line for each architecture with different sub platforms
oring to it will look messy.

With regards
Maddy

> you only put it in one place, and folks only have to care if they want
> to change the default to be something other than 4.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

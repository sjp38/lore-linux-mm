Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 468766B0005
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 23:40:33 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id jq7so12217548obb.0
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 20:40:33 -0800 (PST)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id j138si14841599oih.51.2016.02.14.20.40.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 14 Feb 2016 20:40:32 -0800 (PST)
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 14 Feb 2016 21:40:32 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 75E211FF001F
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:28:39 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1F4eT4932637146
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:40:29 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1F4eTmM006674
	for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:40:29 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 07/29] mm: Make vm_get_page_prot arch specific.
In-Reply-To: <20160215032124.GB3797@oak.ozlabs.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1454923241-6681-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20160215032124.GB3797@oak.ozlabs.ibm.com>
Date: Mon, 15 Feb 2016 10:10:24 +0530
Message-ID: <87io1qfux3.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@ozlabs.org> writes:

> On Mon, Feb 08, 2016 at 02:50:19PM +0530, Aneesh Kumar K.V wrote:
>> With next generation power processor, we are having a new mmu model
>> [1] that require us to maintain a different linux page table format.
>> 
>> Inorder to support both current and future ppc64 systems with a single
>> kernel we need to make sure kernel can select between different page
>> table format at runtime. With the new MMU (radix MMU) added, we will
>> have to dynamically switch between different protection map. Hence
>> override vm_get_page_prot instead of using arch_vm_get_page_prot. We
>> also drop arch_vm_get_page_prot since only powerpc used it.
>
> What's different about ISA v3.0 that means that the protection_map[]
> entries need to be different?
>
> If it's just different bit assignments for things like _PAGE_READ
> etc., couldn't we fix this up at early boot time by writing new values
> into protection_map[]?  Is there a reason why that wouldn't work, or
> why you don't want to do that?
>

Yes, that is other way to do this. But I thought it is easier to have
different protection_map array for radix and hash. That made the code
more readable.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

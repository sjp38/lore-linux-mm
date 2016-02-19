Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADD16B026C
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 21:40:36 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id y89so52336944qge.2
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 18:40:36 -0800 (PST)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id c205si11619675qhc.97.2016.02.18.18.40.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Feb 2016 18:40:35 -0800 (PST)
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 18 Feb 2016 19:40:34 -0700
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 040B119D803F
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 19:28:29 -0700 (MST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1J2eVls30802172
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 02:40:31 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1J2eUHD014498
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 21:40:31 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V3 01/30] mm: Make vm_get_page_prot arch specific.
In-Reply-To: <56C66FBB.7000808@intel.com>
References: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1455814254-10226-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <56C66FBB.7000808@intel.com>
Date: Fri, 19 Feb 2016 08:10:26 +0530
Message-ID: <87bn7de82t.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Dave Hansen <dave.hansen@intel.com> writes:

> On 02/18/2016 08:50 AM, Aneesh Kumar K.V wrote:
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
> Hi Aneesh,
>
> I've got some patches I'm hoping to get in to 4.6 that start using
> arch_vm_get_page_prot() on x86:
>
>> http://git.kernel.org/cgit/linux/kernel/git/daveh/x86-pkeys.git/commit/?h=pkeys-v024&id=aa1e61398fb598869981cfe48275cff832945669
>
> So I'd prefer that it stay in place. :)

Ok. I will update the patch to keep that.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6FBA36B0009
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 21:34:22 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id is5so9269208obc.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 18:34:22 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id u2si705753oig.3.2016.02.09.18.34.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Feb 2016 18:34:21 -0800 (PST)
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 9 Feb 2016 19:34:21 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id C90C53E40044
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 19:34:19 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1A2YJlE29884628
	for <linux-mm@kvack.org>; Tue, 9 Feb 2016 19:34:19 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1A2YJZE008997
	for <linux-mm@kvack.org>; Tue, 9 Feb 2016 19:34:19 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2] mm: Some arch may want to use HPAGE_PMD related values as variables
In-Reply-To: <20160209194206.GA22327@node.shutemov.name>
References: <1455034304-15301-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20160209194206.GA22327@node.shutemov.name>
Date: Wed, 10 Feb 2016 08:04:14 +0530
Message-ID: <87lh6txpi1.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, mpe@ellerman.id.au, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Tue, Feb 09, 2016 at 09:41:44PM +0530, Aneesh Kumar K.V wrote:
>> With next generation power processor, we are having a new mmu model
>> [1] that require us to maintain a different linux page table format.
>> 
>> Inorder to support both current and future ppc64 systems with a single
>> kernel we need to make sure kernel can select between different page
>> table format at runtime. With the new MMU (radix MMU) added, we will
>> have two different pmd hugepage size 16MB for hash model and 2MB for
>> Radix model. Hence make HPAGE_PMD related values as a variable.
>> 
>> [1] http://ibm.biz/power-isa3 (Needs registration).
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> I guess it should have my signed-off-by ;)
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Thanks will update. I will also update the From:

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

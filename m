Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC91828DF
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 23:15:07 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id 9so80443533iom.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 20:15:07 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id e5si1269466igz.45.2016.02.11.20.15.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 20:15:04 -0800 (PST)
Date: Fri, 12 Feb 2016 13:49:06 +1100
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [PATCH V2 01/29] powerpc/mm: add _PAGE_HASHPTE similar to 4K hash
Message-ID: <20160212024906.GB13831@oak.ozlabs.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1454923241-6681-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454923241-6681-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, Feb 08, 2016 at 02:50:13PM +0530, Aneesh Kumar K.V wrote:
> Not really needed. But this brings it back to as it was before

If it's not really needed, what's the motivation for putting this
patch in?  You need to explain where you are heading with this patch.

> Check this
> 41743a4e34f0777f51c1cf0675b91508ba143050

The SHA1 is useful, but you need to be more explicit - something like

"This partially reverts commit 41743a4e34f0 ("powerpc: Free a PTE bit
on ppc64 with 64K pages", 2008-06-11)."

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

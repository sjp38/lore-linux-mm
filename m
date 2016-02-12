Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id A46FA6B0253
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 23:15:05 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id ik10so3043147igb.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 20:15:05 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id p185si17455553ioe.189.2016.02.11.20.15.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 20:15:04 -0800 (PST)
Date: Fri, 12 Feb 2016 13:52:38 +1100
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Re: [PATCH V2 02/29] powerpc/mm: Split pgtable types to separate
 header
Message-ID: <20160212025238.GC13831@oak.ozlabs.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1454923241-6681-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454923241-6681-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, Feb 08, 2016 at 02:50:14PM +0530, Aneesh Kumar K.V wrote:
> We remove real_pte_t out of STRICT_MM_TYPESCHECK. We will later add
> a radix variant that is big endian
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

It looks like most of what this patch does is move a bunch of
definitions from page.h to a new pgtable-types.h.  What is the
motivation for this?  Is the code identical (pure code movement) or do
you make changes along the way, and if so, what and why?

What exactly are you doing with real_pte_t and why?

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 645AB6B0006
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 00:38:54 -0500 (EST)
Date: Fri, 22 Feb 2013 16:06:07 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [RFC PATCH -V2 03/21] powerpc: Don't hard code the size of pte
 page
Message-ID: <20130222050607.GC6139@drongo>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1361465248-10867-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1361465248-10867-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, Feb 21, 2013 at 10:17:10PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> USE PTRS_PER_PTE to indicate the size of pte page.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> powerpc: Don't hard code the size of pte page
> 
> USE PTRS_PER_PTE to indicate the size of pte page.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Description and signoff are duplicated.  Description could be more
informative, for example - why would we want to do this?

> +/*
> + * hidx is in the second half of the page table. We use the
> + * 8 bytes per each pte entry.

The casual reader probably wouldn't know what "hidx" is.  The comment
needs at least to use a better name than "hidx".

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

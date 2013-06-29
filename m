Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 1D29C6B0038
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 03:43:32 -0400 (EDT)
Date: Sat, 29 Jun 2013 17:28:03 +1000
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V2 3/4] powerpc: Contiguous memory allocator based RMA
 allocation
Message-ID: <20130629072803.GD8687@iris.ozlabs.ibm.com>
References: <1372410662-3748-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1372410662-3748-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372410662-3748-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, linuxppc-dev@lists.ozlabs.org

On Fri, Jun 28, 2013 at 02:41:01PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Use CMA for allocation of RMA region for guest. Also remove linear allocator
> now that it is not used
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Paul Mackerras <paulus@samba.org>

... though it could use a more extensive patch description.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id C34DD6B0032
	for <linux-mm@kvack.org>; Sat, 29 Jun 2013 03:43:31 -0400 (EDT)
Date: Sat, 29 Jun 2013 17:43:23 +1000
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V2 4/4] powerpc/kvm: Use 256K chunk to track both RMA
 and hash page table allocation.
Message-ID: <20130629074323.GE8687@iris.ozlabs.ibm.com>
References: <1372410662-3748-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1372410662-3748-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372410662-3748-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, linuxppc-dev@lists.ozlabs.org

On Fri, Jun 28, 2013 at 02:41:02PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Both RMA and hash page table request will be a multiple of 256K. We can use
> a chunk size of 256K to track the free/used 256K chunk in the bitmap. This
> should help to reduce the bitmap size.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Looks good overall, just some minor comments below:

> +	int chunk_count, nr_chunk;

I get a little nervous when I see "int" used for variables storing a
number of pages or related things such as chunks.  Yes, int is enough
today but one day it won't be, and there is no time or space penalty
to using "long" instead, and in fact the code generated "long"
variables can be slightly shorter.  So please make variables like this
"long".  (That will require changes to earlier patches in this
series.)

> +	 * aling mask with chunk size. The bit tracks pages in chunk size

Should be "align".

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

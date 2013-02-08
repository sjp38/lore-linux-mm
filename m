Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 689006B0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 15:48:50 -0500 (EST)
Message-ID: <51156494.3050300@zytor.com>
Date: Fri, 08 Feb 2013 12:48:20 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] make /dev/kmem return error for highmem
References: <20130208202813.62965F25@kernel.stglabs.ibm.com> <20130208202814.E1196596@kernel.stglabs.ibm.com>
In-Reply-To: <20130208202814.E1196596@kernel.stglabs.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, bp@alien8.de, mingo@kernel.org, tglx@linutronix.de

On 02/08/2013 12:28 PM, Dave Hansen wrote:
> I was auding the /dev/mem code for more questionable uses of
> __pa(), and ran across this.
>
> My assumption is that if you use /dev/kmem, you expect to be
> able to read the kernel virtual mappings.  However, those
> mappings _stop_ as soon as we hit high memory.  The
> pfn_valid() check in here is good for memory holes, but since
> highmem pages are still valid, it does no good for those.
>
> Also, since we are now checking that __pa() is being done on
> valid virtual addresses, this might have tripped the new
> check.  Even with the new check, this code would have been
> broken with the NUMA remapping code had we not ripped it
> out:
>

It would be great if you could take a stab at fixing /dev/mem and 
/dev/kmem... there are a bunch of problems with both which seem to 
really translate to "HIGHMEM was never properly implemented"...

	-hpa


-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

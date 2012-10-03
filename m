Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 112846B0074
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 00:44:31 -0400 (EDT)
Message-ID: <506BC2A0.8060500@zytor.com>
Date: Tue, 02 Oct 2012 21:44:16 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Fix devmem_is_allowed for below 1MB accesses for an efi
 machine
References: <1349213536-3436-1-git-send-email-tmac@hp.com> <506B6191.6080605@zytor.com> <20121003043116.GA26241@srcf.ucam.org>
In-Reply-To: <20121003043116.GA26241@srcf.ucam.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Garrett <mjg@redhat.com>
Cc: T Makphaibulchoke <tmac@hp.com>, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, akpm@linux-foundation.org, yinghai@kernel.org, tiwai@suse.de, viro@zeniv.linux.org.uk, aarcange@redhat.com, tony.luck@intel.com, mgorman@suse.de, weiyang@linux.vnet.ibm.com, octavian.purdila@intel.com, paul.gortmaker@windriver.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/02/2012 09:31 PM, Matthew Garrett wrote:
> On Tue, Oct 02, 2012 at 02:50:09PM -0700, H. Peter Anvin wrote:
> 
>> That sounds like exactly the opposite of normal /dev/mem behavior... we
>> allow access to non-memory resources (which really could do anything if
>> misused), but not memory.
> 
> From arch/x86/mm/init.c:
> 
>  * On x86, access has to be given to the first megabyte of ram because that area
>  * contains bios code and data regions used by X and dosemu and similar apps.
> 
> Limiting this to just RAM would be safer than it currently is. I'm not 
> convinced that there's any good reason to allow *any* access down there 
> for EFI systems, though.
> 

Sorry, fail.

We *always* expose the I/O regions to /dev/mem.  That is what /dev/mem
*does*.  The above is an exception (which is really obsolete, too: we
should simply disallow access to anything which is treated as system
RAM, which doesn't include the BIOS regions in question; the only reason
we don't is that some versions of X take a checksum of the RAM in the
first megabyte as some kind of idiotic random seed.)

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id DF0996B006E
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 01:15:51 -0400 (EDT)
Date: Wed, 3 Oct 2012 06:15:22 +0100
From: Matthew Garrett <mjg@redhat.com>
Subject: Re: [PATCH] Fix devmem_is_allowed for below 1MB accesses for an
 efi machine
Message-ID: <20121003051522.GA27113@srcf.ucam.org>
References: <1349213536-3436-1-git-send-email-tmac@hp.com>
 <506B6191.6080605@zytor.com>
 <20121003043116.GA26241@srcf.ucam.org>
 <506BC2A0.8060500@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <506BC2A0.8060500@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: T Makphaibulchoke <tmac@hp.com>, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, akpm@linux-foundation.org, yinghai@kernel.org, tiwai@suse.de, viro@zeniv.linux.org.uk, aarcange@redhat.com, tony.luck@intel.com, mgorman@suse.de, weiyang@linux.vnet.ibm.com, octavian.purdila@intel.com, paul.gortmaker@windriver.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 02, 2012 at 09:44:16PM -0700, H. Peter Anvin wrote:

> We *always* expose the I/O regions to /dev/mem.  That is what /dev/mem
> *does*.  The above is an exception (which is really obsolete, too: we
> should simply disallow access to anything which is treated as system
> RAM, which doesn't include the BIOS regions in question; the only reason
> we don't is that some versions of X take a checksum of the RAM in the
> first megabyte as some kind of idiotic random seed.)

Oh, right, got you. In that case I think we potentially need a 
finer-grained check on EFI platforms - the EFI memory map is kind enough 
to tell us the difference between unusable regions and io regions, and 
we could avoid access to the unusable ones.

-- 
Matthew Garrett | mjg59@srcf.ucam.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

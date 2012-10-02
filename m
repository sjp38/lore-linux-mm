Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id C35036B0070
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 17:50:25 -0400 (EDT)
Message-ID: <506B6191.6080605@zytor.com>
Date: Tue, 02 Oct 2012 14:50:09 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Fix devmem_is_allowed for below 1MB accesses for an efi
 machine
References: <1349213536-3436-1-git-send-email-tmac@hp.com>
In-Reply-To: <1349213536-3436-1-git-send-email-tmac@hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: T Makphaibulchoke <tmac@hp.com>
Cc: tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, akpm@linux-foundation.org, yinghai@kernel.org, tiwai@suse.de, viro@zeniv.linux.org.uk, aarcange@redhat.com, tony.luck@intel.com, mgorman@suse.de, weiyang@linux.vnet.ibm.com, octavian.purdila@intel.com, paul.gortmaker@windriver.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/02/2012 02:32 PM, T Makphaibulchoke wrote:
> Changing devmem_is_allowed so that on an EFI machine, access to physical
> address below 1 MB is allowed only to physical pages that are valid in
> the EFI memory map.  This prevents the possibility of an MCE due to
> accessing an invalid physical address.

What?

That sounds like exactly the opposite of normal /dev/mem behavior... we
allow access to non-memory resources (which really could do anything if
misused), but not memory.

You seem like you're flipping it on its head.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

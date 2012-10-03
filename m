Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 07DED6B005D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 01:36:00 -0400 (EDT)
Message-ID: <506BCEAB.4090204@zytor.com>
Date: Tue, 02 Oct 2012 22:35:39 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Fix devmem_is_allowed for below 1MB accesses for an efi
 machine
References: <1349213536-3436-1-git-send-email-tmac@hp.com> <506B6191.6080605@zytor.com> <20121003043116.GA26241@srcf.ucam.org> <506BC2A0.8060500@zytor.com> <20121003051522.GA27113@srcf.ucam.org> <506BC96D.10507@hp.com> <20121003052803.GA27464@srcf.ucam.org>
In-Reply-To: <20121003052803.GA27464@srcf.ucam.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Garrett <mjg@redhat.com>
Cc: Thavatchai Makphaibulchoke <thavatchai.makpahibulchoke@hp.com>, T Makphaibulchoke <tmac@hp.com>, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, akpm@linux-foundation.org, yinghai@kernel.org, tiwai@suse.de, viro@zeniv.linux.org.uk, aarcange@redhat.com, tony.luck@intel.com, mgorman@suse.de, weiyang@linux.vnet.ibm.com, octavian.purdila@intel.com, paul.gortmaker@windriver.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/02/2012 10:28 PM, Matthew Garrett wrote:
> On Tue, Oct 02, 2012 at 11:13:17PM -0600, Thavatchai Makphaibulchoke wrote:
> 
>> Sounds like a better solution is to allow accesses to only I/O regions 
>> presented in the EFI memory map for physical addresses below 1 MB.
> 
> That won't work - unfortunately we do still need the low region to be 
> available for X because some platforms expect us to use int10 even on 
> EFI (yes, yes, I know). Do you have a copy of the EFI memory map for a 
> system that's broken with the current code?
> 

I honestly think this calls for a quirk, or more likely, no action at
all ("don't do that, then.")

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

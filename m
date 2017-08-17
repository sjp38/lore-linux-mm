Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 721616B04A2
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 18:09:46 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y44so12269643wrd.13
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 15:09:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 135si22432wmg.66.2017.08.17.15.09.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 15:09:45 -0700 (PDT)
Date: Thu, 17 Aug 2017 15:09:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH-resend] mm/hwpoison: Clear PRESENT bit for kernel 1:1
 mappings of poison pages
Message-Id: <20170817150942.017f87537b6cbb48e9cfc082@linux-foundation.org>
In-Reply-To: <20170816171803.28342-1-tony.luck@intel.com>
References: <CAPcyv4gC_6TpwVSjuOzxrz3OdVZCVWD0QVWhBzAuOxUNHJHRMQ@mail.gmail.com>
	<20170816171803.28342-1-tony.luck@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Borislav Petkov <bp@suse.de>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 16 Aug 2017 10:18:03 -0700 "Luck, Tony" <tony.luck@intel.com> wrote:

> Speculative processor accesses may reference any memory that has a
> valid page table entry.  While a speculative access won't generate
> a machine check, it will log the error in a machine check bank. That
> could cause escalation of a subsequent error since the overflow bit
> will be then set in the machine check bank status register.
> 
> Code has to be double-plus-tricky to avoid mentioning the 1:1 virtual
> address of the page we want to map out otherwise we may trigger the
> very problem we are trying to avoid.  We use a non-canonical address
> that passes through the usual Linux table walking code to get to the
> same "pte".
> 
> Thanks to Dave Hansen for reviewing several iterations of this.

It's unclear (to lil ole me) what the end-user-visible effects of this
are.

Could we please have a description of that?  So a) people can
understand your decision to cc:stable and b) people whose kernels are
misbehaving can use your description to decide whether your patch might
fix the issue their users are reporting.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

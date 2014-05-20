Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 42DDE6B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 03:32:24 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so69326pab.21
        for <linux-mm@kvack.org>; Tue, 20 May 2014 00:32:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id bi10si23374887pad.76.2014.05.20.00.32.23
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 00:32:23 -0700 (PDT)
Date: Tue, 20 May 2014 00:32:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data
 for powerpc
Message-Id: <20140520003201.a2360d5d.akpm@linux-foundation.org>
In-Reply-To: <87oaythsvk.fsf@rustcorp.com.au>
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com>
	<537479E7.90806@linux.vnet.ibm.com>
	<alpine.LSU.2.11.1405151026540.4664@eggly.anvils>
	<87wqdik4n5.fsf@rustcorp.com.au>
	<53797511.1050409@linux.vnet.ibm.com>
	<alpine.LSU.2.11.1405191531150.1317@eggly.anvils>
	<20140519164301.eafd3dd288ccb88361ddcfc7@linux-foundation.org>
	<20140520004429.E660AE009B@blue.fi.intel.com>
	<87oaythsvk.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

On Tue, 20 May 2014 15:52:07 +0930 Rusty Russell <rusty@rustcorp.com.au> wrote:

> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> > Andrew Morton wrote:
> >> On Mon, 19 May 2014 16:23:07 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> >> 
> >> > Shouldn't FAULT_AROUND_ORDER and fault_around_order be changed to be
> >> > the order of the fault-around size in bytes, and fault_around_pages()
> >> > use 1UL << (fault_around_order - PAGE_SHIFT)
> >> 
> >> Yes.  And shame on me for missing it (this time!) at review.
> >> 
> >> There's still time to fix this.  Patches, please.
> >
> > Here it is. Made at 3.30 AM, build tested only.
> 
> Prefer on top of Maddy's patch which makes it always a variable, rather
> than CONFIG_DEBUG_FS.  It's got enough hair as it is.
> 

We're at 3.15-rc5 and this interface should be finalised for 3.16.  So
Kirrill's patch is pretty urgent and should come first.

Well.  It's only a debugfs interface at this stage so we are allowed to
change it later, but it's better not to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E1BF96B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 03:17:10 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kq14so55377pab.33
        for <linux-mm@kvack.org>; Tue, 20 May 2014 00:17:10 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id kv4si9762027pab.78.2014.05.20.00.17.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 May 2014 00:17:09 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data for powerpc
In-Reply-To: <20140520004429.E660AE009B@blue.fi.intel.com>
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com> <537479E7.90806@linux.vnet.ibm.com> <alpine.LSU.2.11.1405151026540.4664@eggly.anvils> <87wqdik4n5.fsf@rustcorp.com.au> <53797511.1050409@linux.vnet.ibm.com> <alpine.LSU.2.11.1405191531150.1317@eggly.anvils> <20140519164301.eafd3dd288ccb88361ddcfc7@linux-foundation.org> <20140520004429.E660AE009B@blue.fi.intel.com>
Date: Tue, 20 May 2014 15:52:07 +0930
Message-ID: <87oaythsvk.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> Andrew Morton wrote:
>> On Mon, 19 May 2014 16:23:07 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
>> 
>> > Shouldn't FAULT_AROUND_ORDER and fault_around_order be changed to be
>> > the order of the fault-around size in bytes, and fault_around_pages()
>> > use 1UL << (fault_around_order - PAGE_SHIFT)
>> 
>> Yes.  And shame on me for missing it (this time!) at review.
>> 
>> There's still time to fix this.  Patches, please.
>
> Here it is. Made at 3.30 AM, build tested only.

Prefer on top of Maddy's patch which makes it always a variable, rather
than CONFIG_DEBUG_FS.  It's got enough hair as it is.

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

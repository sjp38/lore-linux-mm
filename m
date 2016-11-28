Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 313C86B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 03:37:19 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y68so204842241pfb.6
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 00:37:19 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id o86si54183191pfj.154.2016.11.28.00.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 00:37:18 -0800 (PST)
Date: Mon, 28 Nov 2016 16:37:15 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH 0/2] use mmu gather logic for tlb flush in mremap
Message-ID: <20161128083715.GA21738@aaronlu.sh.intel.com>
References: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
 <CA+55aFzHfpZckv8ck19fZSFK+3TmR5eF=BsDzhwVGKrbyEBjEw@mail.gmail.com>
 <c160bc18-7c1b-2d54-8af1-7c5bfcbcefe8@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c160bc18-7c1b-2d54-8af1-7c5bfcbcefe8@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org

On Fri, Nov 18, 2016 at 10:48:20AM +0800, Aaron Lu wrote:
> On 11/18/2016 01:53 AM, Linus Torvalds wrote:
> > I'm not entirely happy with the force_flush vs need_flush games, and I
> > really think this code should be updated to use the same "struct
> > mmu_gather" that we use for the other TLB flushing cases (no need for
> > the page freeing batching, but the tlb_flush_mmu_tlbonly() logic
> > should be the same).
> 
> I see.
> 
> > 
> > But I guess that's a bigger change, so that wouldn't be approriate for
> > rc5 or stable back-porting anyway. But it would be lovely if somebody
> > could look at that. Hint hint.
> 
> I'll work on it, thanks for the suggestion.

So here it is. I'm not quite sure if I've done the right thing in patch
2/2, i.e. should I just use tlb_flush_mmu or export tlb_flush_mmu_tlbonly
and then use it in mremap.c. Please take a look and let me know what you
think, thanks!

Regards,
Aaron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

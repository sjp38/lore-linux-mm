Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 920146B027C
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 05:33:02 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b80so6596031wme.5
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 02:33:02 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id r184si2057823wmr.128.2016.10.27.02.33.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 02:33:01 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id c17so1716546wmc.3
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 02:33:01 -0700 (PDT)
Date: Thu, 27 Oct 2016 10:32:59 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH v2] mm: remove unnecessary __get_user_pages_unlocked()
 calls
Message-ID: <20161027093259.GA1135@lucifer>
References: <20161025233609.5601-1-lstoakes@gmail.com>
 <20161026092548.12712-1-lstoakes@gmail.com>
 <20161026171207.e76e4420dd95afcf16cc7c59@linux-foundation.org>
 <1019451e-1f91-57d4-11c8-79e08c86afe1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1019451e-1f91-57d4-11c8-79e08c86afe1@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 27, 2016 at 11:27:24AM +0200, Paolo Bonzini wrote:
>
>
> On 27/10/2016 02:12, Andrew Morton wrote:
> >
> >
> >> Subject: [PATCH v2] mm: remove unnecessary __get_user_pages_unlocked() calls
> >
> > The patch is rather misidentified.
> >
> >>  virt/kvm/async_pf.c | 7 ++++---
> >>  virt/kvm/kvm_main.c | 5 ++---
> >>  2 files changed, 6 insertions(+), 6 deletions(-)
> >
> > It's a KVM patch and should have been called "kvm: remove ...".
> > Possibly the KVM maintainers will miss it for this reason.
>
> I noticed it, but I confused it with "mm: unexport __get_user_pages()".
>
> I'll merge this through the KVM tree for -rc3.

Actually Paolo could you hold off on this? As I think on reflection it'd make
more sense to batch this change up with a change to get_user_pages_remote() as
suggested by Michal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

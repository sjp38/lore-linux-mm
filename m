Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id F351C6B025E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:30:21 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z142so127186137qkb.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:30:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 12si25858652qtw.33.2016.06.16.03.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 03:30:21 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH] Revert "mm: rename _count, field of the struct page, to _refcount"
References: <1466068966-24620-1-git-send-email-vkuznets@redhat.com>
	<20160616093235.GA14640@infradead.org>
Date: Thu, 16 Jun 2016 12:30:16 +0200
In-Reply-To: <20160616093235.GA14640@infradead.org> (Christoph Hellwig's
	message of "Thu, 16 Jun 2016 02:32:35 -0700")
Message-ID: <87eg7xfmtj.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>

Christoph Hellwig <hch@infradead.org> writes:

> On Thu, Jun 16, 2016 at 11:22:46AM +0200, Vitaly Kuznetsov wrote:
>> _count -> _refcount rename in commit 0139aa7b7fa12 ("mm: rename _count,
>> field of the struct page, to _refcount") broke kdump. makedumpfile(8) does
>> stuff like READ_MEMBER_OFFSET("page._count", page._count) and fails. While
>> it is definitely possible to fix this particular tool I'm not sure about
>> other tools which might be doing the same.
>> 
>> I suggest we remember the "we don't break userspace" rule and revert for
>> 4.7 while it's not too late.
>
> Err, sorry - this is not "userspace".  It's crazy crap digging into
> kernel internal structure.
>
> The rename was absolutely useful, so fix up your stinking pike in kdump.

Ok, sure, I'll send a patch to it. I was worried about other tools out
there which e.g. inspect /proc/vmcore. As it is something we support
some conservatism around it is justified.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4868A6B025F
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:22:33 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id v78so43537692ywa.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:22:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 5si26053263qgo.94.2016.06.16.04.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 04:22:32 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH] Revert "mm: rename _count, field of the struct page, to _refcount"
References: <1466068966-24620-1-git-send-email-vkuznets@redhat.com>
	<20160616093235.GA14640@infradead.org>
	<87eg7xfmtj.fsf@vitty.brq.redhat.com>
	<20160616105928.GA12437@dhcp22.suse.cz>
Date: Thu, 16 Jun 2016 13:22:27 +0200
In-Reply-To: <20160616105928.GA12437@dhcp22.suse.cz> (Michal Hocko's message
	of "Thu, 16 Jun 2016 12:59:28 +0200")
Message-ID: <87a8ilfkek.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>

Michal Hocko <mhocko@kernel.org> writes:

> On Thu 16-06-16 12:30:16, Vitaly Kuznetsov wrote:
>> Christoph Hellwig <hch@infradead.org> writes:
>> 
>> > On Thu, Jun 16, 2016 at 11:22:46AM +0200, Vitaly Kuznetsov wrote:
>> >> _count -> _refcount rename in commit 0139aa7b7fa12 ("mm: rename _count,
>> >> field of the struct page, to _refcount") broke kdump. makedumpfile(8) does
>> >> stuff like READ_MEMBER_OFFSET("page._count", page._count) and fails. While
>> >> it is definitely possible to fix this particular tool I'm not sure about
>> >> other tools which might be doing the same.
>> >> 
>> >> I suggest we remember the "we don't break userspace" rule and revert for
>> >> 4.7 while it's not too late.
>> >
>> > Err, sorry - this is not "userspace".  It's crazy crap digging into
>> > kernel internal structure.
>> >
>> > The rename was absolutely useful, so fix up your stinking pike in kdump.
>> 
>> Ok, sure, I'll send a patch to it. I was worried about other tools out
>> there which e.g. inspect /proc/vmcore. As it is something we support
>> some conservatism around it is justified.
>
> struct page layout as some others that such a tool might depend on has
> changes several times in the past so I fail to see how is it any
> different this time.

IMO this time the change doesn't give us any advantage, it was just a
rename.

> struct page is nothing the userspace should depend on.

True but at least makedumpfile(8) is special and even if it's a 'crazy
crap digging into ...' we could avoid breaking it for no technical
reason.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 86C6A6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 05:36:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c82so24138004wme.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:36:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v82si3573254wmv.10.2016.06.16.02.36.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 02:36:52 -0700 (PDT)
Subject: Re: [PATCH] Revert "mm: rename _count, field of the struct page, to
 _refcount"
References: <1466068966-24620-1-git-send-email-vkuznets@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d7049c89-7b78-ee1c-7216-90d8dd69d1b5@suse.cz>
Date: Thu, 16 Jun 2016 11:36:47 +0200
MIME-Version: 1.0
In-Reply-To: <1466068966-24620-1-git-send-email-vkuznets@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org
Cc: kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>

On 06/16/2016 11:22 AM, Vitaly Kuznetsov wrote:
> _count -> _refcount rename in commit 0139aa7b7fa12 ("mm: rename _count,
> field of the struct page, to _refcount") broke kdump. makedumpfile(8) does
> stuff like READ_MEMBER_OFFSET("page._count", page._count) and fails. While
> it is definitely possible to fix this particular tool I'm not sure about
> other tools which might be doing the same.
>
> I suggest we remember the "we don't break userspace" rule and revert for
> 4.7 while it's not too late.

I don't think the rule applies to tools such as kdump and crash, or e.g. 
systemtap, that interact with kernel internals even though they are 
technically "userspace". They have to adapt to new kernel versions all 
the time, the internal APIs are not frozen. Otherwise we would be quite 
limited in evolving the kernel...

So even though the change in question is not essential (field rename) 
and reverting wouldn't really hurt technical progress, this is not a 
sufficient reason, IMO. Thus, NAK.

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

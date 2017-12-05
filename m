Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 20EE16B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 01:19:51 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id p1so15392624pfp.13
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 22:19:51 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z19si10427437pgv.738.2017.12.04.22.19.49
        for <linux-mm@kvack.org>;
        Mon, 04 Dec 2017 22:19:49 -0800 (PST)
Subject: Re: [PATCH v2 0/4] lockdep/crossrelease: Apply crossrelease to page
 locks
From: Byungchul Park <byungchul.park@lge.com>
References: <1512364583-26070-1-git-send-email-byungchul.park@lge.com>
 <20171205053023.GB20757@bombadil.infradead.org>
 <0aad02e4-f477-1ee3-471a-3e1371ebba1e@lge.com>
Message-ID: <55674f0a-7886-f1d2-d7f1-6bf42c1e89e3@lge.com>
Date: Tue, 5 Dec 2017 15:19:46 +0900
MIME-Version: 1.0
In-Reply-To: <0aad02e4-f477-1ee3-471a-3e1371ebba1e@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, mhocko@suse.com, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

On 12/5/2017 2:46 PM, Byungchul Park wrote:
> On 12/5/2017 2:30 PM, Matthew Wilcox wrote:
>> On Mon, Dec 04, 2017 at 02:16:19PM +0900, Byungchul Park wrote:
>>> For now, wait_for_completion() / complete() works with lockdep, add
>>> lock_page() / unlock_page() and its family to lockdep support.
>>>
>>> Changes from v1
>>> A  - Move lockdep_map_cross outside of page_ext to make it flexible
>>> A  - Prevent allocating lockdep_map per page by default
>>> A  - Add a boot parameter allowing the allocation for debugging
>>>
>>> Byungchul Park (4):
>>> A A  lockdep: Apply crossrelease to PG_locked locks
>>> A A  lockdep: Apply lock_acquire(release) on __Set(__Clear)PageLocked
>>> A A  lockdep: Move data of CONFIG_LOCKDEP_PAGELOCK from page to page_ext
>>> A A  lockdep: Add a boot parameter enabling to track page locks using
>>> A A A A  lockdep and disable it by default
>>
>> I don't like the way you've structured this patch series; first adding
>> the lockdep map to struct page, then moving it to page_ext.
> 
> Hello,
> 
> I will make them into one patch.

I've thought it more.

Actually I did it because I thought I'd better make it into two
patches since it makes reviewers easier to review. It doesn't matter
which one I choose, but I prefer to split it.

But, if you are strongly against it, then I will follow you.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

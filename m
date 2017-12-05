Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4EC6B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 00:46:52 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id j26so15244042pff.8
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 21:46:52 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id c6si7189689pgn.510.2017.12.04.21.46.50
        for <linux-mm@kvack.org>;
        Mon, 04 Dec 2017 21:46:51 -0800 (PST)
Subject: Re: [PATCH v2 0/4] lockdep/crossrelease: Apply crossrelease to page
 locks
References: <1512364583-26070-1-git-send-email-byungchul.park@lge.com>
 <20171205053023.GB20757@bombadil.infradead.org>
From: Byungchul Park <byungchul.park@lge.com>
Message-ID: <0aad02e4-f477-1ee3-471a-3e1371ebba1e@lge.com>
Date: Tue, 5 Dec 2017 14:46:48 +0900
MIME-Version: 1.0
In-Reply-To: <20171205053023.GB20757@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, mhocko@suse.com, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

On 12/5/2017 2:30 PM, Matthew Wilcox wrote:
> On Mon, Dec 04, 2017 at 02:16:19PM +0900, Byungchul Park wrote:
>> For now, wait_for_completion() / complete() works with lockdep, add
>> lock_page() / unlock_page() and its family to lockdep support.
>>
>> Changes from v1
>>   - Move lockdep_map_cross outside of page_ext to make it flexible
>>   - Prevent allocating lockdep_map per page by default
>>   - Add a boot parameter allowing the allocation for debugging
>>
>> Byungchul Park (4):
>>    lockdep: Apply crossrelease to PG_locked locks
>>    lockdep: Apply lock_acquire(release) on __Set(__Clear)PageLocked
>>    lockdep: Move data of CONFIG_LOCKDEP_PAGELOCK from page to page_ext
>>    lockdep: Add a boot parameter enabling to track page locks using
>>      lockdep and disable it by default
> 
> I don't like the way you've structured this patch series; first adding
> the lockdep map to struct page, then moving it to page_ext.

Hello,

I will make them into one patch.

> I also don't like it that you've made CONFIG_LOCKDEP_PAGELOCK not
> individually selectable.  I might well want a kernel with crosslock
> support, but only for completions.

OK then, I will make it individually selectable.

I want to know others' opinions as well.

Thank you for the opinions. I will apply yours next spin.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

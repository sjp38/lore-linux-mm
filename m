Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id E0C3B6B0036
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 17:18:42 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id ez12so2028606wid.1
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:18:42 -0800 (PST)
Received: from mail-we0-x230.google.com (mail-we0-x230.google.com [2a00:1450:400c:c03::230])
        by mx.google.com with ESMTPS id fy1si11994802wjb.65.2013.11.21.14.18.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 14:18:42 -0800 (PST)
Received: by mail-we0-f176.google.com with SMTP id t61so389493wes.7
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:18:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALZtONByWEv-vyx8+HMn+o53hPO4L_UY-+BbLRrBoWx-u2UejA@mail.gmail.com>
References: <1384976909-32671-1-git-send-email-ddstreet@ieee.org>
 <CAL1ERfPcAbNyt9hTYKMj9OGK2=ynLrTVm9udEn=hF+bFptC16Q@mail.gmail.com> <CALZtONByWEv-vyx8+HMn+o53hPO4L_UY-+BbLRrBoWx-u2UejA@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 21 Nov 2013 17:18:21 -0500
Message-ID: <CALZtONDH1naq7uKOfcqCz+5bREYYd3A5-DN72wJ5TOpZEcaygw@mail.gmail.com>
Subject: Re: [PATCH] mm/zswap: don't allow entry eviction if in use by load
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Thu, Nov 21, 2013 at 4:44 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Wed, Nov 20, 2013 at 8:59 PM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
>> Hello Dan
>>
>> On Thu, Nov 21, 2013 at 3:48 AM, Dan Streetman <ddstreet@ieee.org> wrote:
>>> The changes in commit 0ab0abcf511545d1fddbe72a36b3ca73388ac937
>>> introduce a bug in writeback, if an entry is in use by load
>>> it will be evicted anyway, which isn't correct (technically,
>>> the code currently in zbud doesn't actually care much what the
>>> zswap evict function returns, but that could change).
>>
>> Thanks for your work. Howerver it is not a bug.
>>
>> I have thought about this situation, and it will never happen.
>> If entry is being loaded, its corresponding page must be in swapcache
>> so zswap_get_swap_cache_page() will return ZSWAP_SWAPCACHE_EXIST
>
>
> Can I also ask why you do a rb_search instead of just checking the
> entry->refcount?  Doing the search is going to take longer than just
> checking the refcount; is there some case where the entry will not be
> in the rb but will have a nonzero refcount?

Never mind; I realized the entry will have been free'd once it's
refcount is 0 so that can't be checked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

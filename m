Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 7387C6B005D
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 14:04:36 -0400 (EDT)
Received: by iec9 with SMTP id 9so2375771iec.14
        for <linux-mm@kvack.org>; Sun, 09 Sep 2012 11:04:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <504CCECF.9020104@redhat.com>
References: <5038E7AA.5030107@gmail.com> <1347209830.7709.39.camel@deadeye.wl.decadent.org.uk>
 <504CCECF.9020104@redhat.com>
From: Shentino <shentino@gmail.com>
Date: Sun, 9 Sep 2012 11:03:55 -0700
Message-ID: <CAGDaZ_pLTR3FZy4-txF7ZhMy60xp_BB=-JORd8OhcGcJOG6YCw@mail.gmail.com>
Subject: Re: Consider for longterm kernels: mm: avoid swapping out with swappiness==0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ben Hutchings <ben@decadent.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Zdenek Kaspar <zkaspar82@gmail.com>, linux-mm@kvack.org

On Sun, Sep 9, 2012 at 10:15 AM, Rik van Riel <riel@redhat.com> wrote:
> On 09/09/2012 12:57 PM, Ben Hutchings wrote:
>>
>> On Sat, 2012-08-25 at 16:56 +0200, Zdenek Kaspar wrote:
>>>
>>> Hi Greg,
>>>
>>>
>>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=fe35004fbf9eaf67482b074a2e032abb9c89b1dd
>>>
>>> In short: this patch seems beneficial for users trying to avoid memory
>>> swapping at all costs but they want to keep swap for emergency reasons.
>>>
>>> More details: https://lkml.org/lkml/2012/3/2/320
>>>
>>> Its included in 3.5, so could this be considered for -longterm kernels ?
>>
>>
>> Andrew, Rik, does this seem appropriate for longterm?
>
>
> Yes, absolutely.  Default behaviour is not changed at all, and
> the patch makes swappiness=0 do what people seem to expect it
> to do.

Just curious, but what theoretically would happen if someone were to
want to set swappiness to 200 or something?

Should it be sorta like vfs_cache_pressure?

> --
> All rights reversed
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id AEE9F6B005D
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 13:16:11 -0400 (EDT)
Message-ID: <504CCECF.9020104@redhat.com>
Date: Sun, 09 Sep 2012 13:15:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Consider for longterm kernels: mm: avoid swapping out with swappiness==0
References: <5038E7AA.5030107@gmail.com> <1347209830.7709.39.camel@deadeye.wl.decadent.org.uk>
In-Reply-To: <1347209830.7709.39.camel@deadeye.wl.decadent.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Zdenek Kaspar <zkaspar82@gmail.com>, linux-mm@kvack.org

On 09/09/2012 12:57 PM, Ben Hutchings wrote:
> On Sat, 2012-08-25 at 16:56 +0200, Zdenek Kaspar wrote:
>> Hi Greg,
>>
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=fe35004fbf9eaf67482b074a2e032abb9c89b1dd
>>
>> In short: this patch seems beneficial for users trying to avoid memory
>> swapping at all costs but they want to keep swap for emergency reasons.
>>
>> More details: https://lkml.org/lkml/2012/3/2/320
>>
>> Its included in 3.5, so could this be considered for -longterm kernels ?
>
> Andrew, Rik, does this seem appropriate for longterm?

Yes, absolutely.  Default behaviour is not changed at all, and
the patch makes swappiness=0 do what people seem to expect it
to do.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

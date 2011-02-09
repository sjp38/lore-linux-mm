Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DD8958D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 12:36:10 -0500 (EST)
Received: by vws10 with SMTP id 10so240899vws.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 09:36:07 -0800 (PST)
Message-ID: <4D52D091.1000504@vflare.org>
Date: Wed, 09 Feb 2011 12:36:17 -0500
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH V2 2/3] drivers/staging: zcache: host services and PAM
 services
References: <AANLkTi=CEXiOdqPZgQZmQwatHqZ_nsnmnVhwpdt=7q3f@mail.gmail.com> <0d1aa13e-be1f-4e21-adf2-f0162c67ede3@default AANLkTimm8o6FnDon=eMTepDaoViU9tjteAYE9kmJhMsx@mail.gmail.com> <5c529b08-cf36-43c7-b368-f3f602faf358@default>
In-Reply-To: <5c529b08-cf36-43c7-b368-f3f602faf358@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, gregkh@suse.de, Chris Mason <chris.mason@oracle.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@zeniv.linux.org.uk, hughd@google.com, hannes@cmpxchg.org

On 02/09/2011 11:39 AM, Dan Magenheimer wrote:
>
>
>> From: Minchan Kim [mailto:minchan.kim@gmail.com]
>
>> As I read your comment, I can't find the benefit of zram compared to
>> frontswap.
>
> Well, I am biased, but I agree that frontswap is a better technical
> solution than zram. ;-)  But "dynamic-ity" is very important to
> me and may be less important to others.
>


I agree that frontswap is better than zram when considering swap as the 
use case - no bio overhead, dynamic resizing. However, zram being a 
*generic* block-device has some unique cases too like hosting files on 
/tmp, various caches under /var or any place where a compressed 
in-memory block device can help.

So, frontswap and zram have overlapping use case of swap but are not the 
same.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

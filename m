Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 672586B01B0
	for <linux-mm@kvack.org>; Sun, 23 May 2010 20:09:33 -0400 (EDT)
Received: by iwn39 with SMTP id 39so3233310iwn.14
        for <linux-mm@kvack.org>; Sun, 23 May 2010 17:09:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BF974D5.30207@cesarb.net>
References: <4BF81D87.6010506@cesarb.net>
	<20100523140348.GA10843@barrios-desktop>
	<4BF974D5.30207@cesarb.net>
Date: Mon, 24 May 2010 09:09:31 +0900
Message-ID: <AANLkTil1kwOHAcBpsZ_MdtjLmCAFByvF4xvm8JJ7r7dH@mail.gmail.com>
Subject: Re: [PATCH 0/3] mm: Swap checksum
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

Hi, Cesar.
I am not sure Cesar is first name. :)

On Mon, May 24, 2010 at 3:32 AM, Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> Em 23-05-2010 11:03, Minchan Kim escreveu:
>>
>> On Sat, May 22, 2010 at 03:08:07PM -0300, Cesar Eduardo Barros wrote:
>>>
>>> Add support for checksumming the swap pages written to disk, using the
>>> same checksum as btrfs (crc32c). Since the contents of the swap do not
>>> matter after a shutdown, the checksum is kept in memory only.
>>>
>>> Note that this code does not checksum the software suspend image.
>>
>> We have been used swap pages without checksum.
>>
>> First of all, Could you explain why you need checksum on swap pages?
>> Do you see any problem which swap pages are broken?
>
> The same reason we need checksums in the filesystem.
>
> If you use btrfs as your root filesystem, you are protected by checksums
> from damage in the filesystem, but not in the swap partition (which is often
> in the same disk, and thus as vulnerable as the filesystem). It is better to
> get a checksum error when swapping in than having a silently corrupted page.

Do you mean "vulnerable" is other file system or block I/O operation
invades swap partition and breaks data of swap?

If it is, I think it's the problem of them. so we have to fix it
before merged into mainline. But I admit human being always take a
mistake so that we can miss it at review time. In such case, it would
be very hard bug when swap pages are broken. I haven't hear about such
problem until now but it might be useful if the problem happens.
(Maybe they can't notice that due to hard bug to find)

But I have a concern about breaking memory which includes crc by
dangling pointer. In this case, swap block is correct but it would
emit crc error.

Do you have an idea making sure memory includes crc is correct?

Before review code, let's discuss we really need this and it's useful.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

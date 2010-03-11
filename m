Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ABBE46B00C6
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 04:57:56 -0500 (EST)
Received: by pvh11 with SMTP id 11so2464027pvh.14
        for <linux-mm@kvack.org>; Thu, 11 Mar 2010 01:57:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2375c9f91003101842g713bba07v146a53f12a15a8d7@mail.gmail.com>
References: <2375c9f91003100029q7d64bbf7xce15eee97f7e2190@mail.gmail.com>
	 <4B977282.40505@cs.helsinki.fi>
	 <alpine.DEB.2.00.1003100832200.17615@router.home>
	 <2375c9f91003101842g713bba07v146a53f12a15a8d7@mail.gmail.com>
Date: Thu, 11 Mar 2010 17:57:54 +0800
Message-ID: <2375c9f91003110157y35d26e39odcd8efd9b44d83a1@mail.gmail.com>
Subject: Re: 2.6.34-rc1: kernel BUG at mm/slab.c:2989!
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, viro@zeniv.linux.org.uk, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, roland@redhat.com, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 11, 2010 at 10:42 AM, Am=C3=A9rico Wang <xiyou.wangcong@gmail.c=
om> wrote:
> On Wed, Mar 10, 2010 at 10:33 PM, Christoph Lameter
> <cl@linux-foundation.org> wrote:
>> On Wed, 10 Mar 2010, Pekka Enberg wrote:
>>
>>> > Please let me know if you need more info.
>>>
>>> Looks like regular SLAB corruption bug to me. Can you trigget it with S=
LUB?
>>
>> Run SLUB with CONFIG_SLUB_DEBUG_ON or specify slub_debug on the kernel
>> command line to have all allocations checked.
>>
>>
>
> Ok, I will try it today.
>

Sorry, I can't trigger it today, either with SLAB or SLUB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

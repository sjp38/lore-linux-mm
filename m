Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1180A6B00E3
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 11:15:58 -0500 (EST)
Received: by pvh11 with SMTP id 11so67133pvh.14
        for <linux-mm@kvack.org>; Thu, 11 Mar 2010 08:15:54 -0800 (PST)
Date: Fri, 12 Mar 2010 00:19:05 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: 2.6.34-rc1: kernel BUG at mm/slab.c:2989!
Message-ID: <20100311161905.GB3804@hack>
References: <2375c9f91003100029q7d64bbf7xce15eee97f7e2190@mail.gmail.com> <4B977282.40505@cs.helsinki.fi> <alpine.DEB.2.00.1003100832200.17615@router.home> <2375c9f91003101842g713bba07v146a53f12a15a8d7@mail.gmail.com> <2375c9f91003110157y35d26e39odcd8efd9b44d83a1@mail.gmail.com> <4B98CAC0.5030009@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4B98CAC0.5030009@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, viro@zeniv.linux.org.uk, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, roland@redhat.com, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 11, 2010 at 12:49:36PM +0200, Pekka Enberg wrote:
> AmA(C)rico Wang kirjoitti:
>> On Thu, Mar 11, 2010 at 10:42 AM, AmA(C)rico Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Wed, Mar 10, 2010 at 10:33 PM, Christoph Lameter
>>> <cl@linux-foundation.org> wrote:
>>>> On Wed, 10 Mar 2010, Pekka Enberg wrote:
>>>>
>>>>>> Please let me know if you need more info.
>>>>> Looks like regular SLAB corruption bug to me. Can you trigget it with SLUB?
>>>> Run SLUB with CONFIG_SLUB_DEBUG_ON or specify slub_debug on the kernel
>>>> command line to have all allocations checked.
>>>>
>>>>
>>> Ok, I will try it today.
>>
>> Sorry, I can't trigger it today, either with SLAB or SLUB.
>
> Is it the exact same version or is it a new git snapshot?

No, I did a git pull, but it looks like only some btrfs updates...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

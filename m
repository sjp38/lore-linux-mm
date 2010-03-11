Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1FF036B0096
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 21:42:29 -0500 (EST)
Received: by qw-out-1920.google.com with SMTP id 5so4873949qwf.44
        for <linux-mm@kvack.org>; Wed, 10 Mar 2010 18:42:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1003100832200.17615@router.home>
References: <2375c9f91003100029q7d64bbf7xce15eee97f7e2190@mail.gmail.com>
	 <4B977282.40505@cs.helsinki.fi>
	 <alpine.DEB.2.00.1003100832200.17615@router.home>
Date: Thu, 11 Mar 2010 10:42:25 +0800
Message-ID: <2375c9f91003101842g713bba07v146a53f12a15a8d7@mail.gmail.com>
Subject: Re: 2.6.34-rc1: kernel BUG at mm/slab.c:2989!
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, viro@zeniv.linux.org.uk, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, roland@redhat.com, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 10, 2010 at 10:33 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Wed, 10 Mar 2010, Pekka Enberg wrote:
>
>> > Please let me know if you need more info.
>>
>> Looks like regular SLAB corruption bug to me. Can you trigget it with SLUB?
>
> Run SLUB with CONFIG_SLUB_DEBUG_ON or specify slub_debug on the kernel
> command line to have all allocations checked.
>
>

Ok, I will try it today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

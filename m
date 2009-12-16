Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E20E46B0062
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 05:31:42 -0500 (EST)
Received: by pxi5 with SMTP id 5so596209pxi.12
        for <linux-mm@kvack.org>; Wed, 16 Dec 2009 02:31:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091216102806.GC15031@basil.fritz.box>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091216101107.GA15031@basil.fritz.box>
	 <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091216102806.GC15031@basil.fritz.box>
Date: Wed, 16 Dec 2009 19:31:40 +0900
Message-ID: <28c262360912160231r18db8478sf41349362360cab8@mail.gmail.com>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 16, 2009 at 7:28 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> > Also the patches didn't fare too well in testing unfortunately.
>> >
>> > I suspect we'll rather need multiple locks split per address
>> > space range.
>>
>> This set doesn't include any changes of the logic. Just replace all mmap_sem.
>> I think this is good start point (for introducing another logic etc..)
>
> The problem is that for range locking simple wrapping the locks
> in macros is not enough. You need more changes.

I agree.

We can't justify to merge as only this patch series although this
doesn't change
any behavior.

After we see the further works, let us discuss this patch's value.

Nitpick:
In case of big patch series, it would be better to provide separate
all-at-once patch
with convenience for easy patch and testing. :)

Thanks for great effort. Kame.

>
> -Andi
>
> --
> ak@linux.intel.com -- Speaking for myself only.
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

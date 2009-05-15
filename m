Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 74ED76B005C
	for <linux-mm@kvack.org>; Fri, 15 May 2009 11:21:34 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so988540yxh.26
        for <linux-mm@kvack.org>; Fri, 15 May 2009 08:21:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1242374931.21646.30.camel@penberg-laptop>
References: <1242289830.21646.5.camel@penberg-laptop>
	 <20090514175332.9B7B.A69D9226@jp.fujitsu.com>
	 <20090515083726.F5BF.A69D9226@jp.fujitsu.com>
	 <1242374931.21646.30.camel@penberg-laptop>
Date: Sat, 16 May 2009 00:21:42 +0900
Message-ID: <2f11576a0905150821m5c602ef7g996766ae5d7f0141@mail.gmail.com>
Subject: Re: kernel BUG at mm/slqb.c:1411!
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, matthew.r.wilcox@intel.com
List-ID: <linux-mm.kvack.org>

2009/5/15 Pekka Enberg <penberg@cs.helsinki.fi>:
> Hi Motohiro-san,
>
> On Wed, 2009-05-13 at 17:37 +0900, Minchan Kim wrote:
>> > > > On Wed, 13 May 2009 16:42:37 +0900 (JST)
>> > > > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>> > > >
>> > > > Hmm. I don't know slqb well.
>> > > > So, It's just my guess.
>> > > >
>> > > > We surely increase l->nr_partial in =A0__slab_alloc_page.
>> > > > In between l->nr_partial++ and call __cache_list_get_page, Who is =
decrease l->nr_partial again.
>> > > > After all, __cache_list_get_page return NULL and hit the VM_BUG_ON=
.
>> > > >
>> > > > Comment said :
>> > > >
>> > > > =A0 =A0 =A0 =A0 /* Protects nr_partial, nr_slabs, and partial */
>> > > > =A0 spinlock_t =A0 =A0page_lock;
>> > > >
>> > > > As comment is right, We have to hold the l->page_lock ?
>> > >
>> > > Makes sense. Nick? Motohiro-san, can you try this patch please?
>> >
>> > This issue is very rarely. please give me one night.
>
> On Fri, 2009-05-15 at 08:38 +0900, KOSAKI Motohiro wrote:
>> -ENOTREPRODUCED
>>
>> I guess your patch is right fix. thanks!
>
> Thank you so much for testing!
>
> Nick seems to have gone silent for the past few days so I went ahead and
> merged the patch.
>
> Did you have CONFIG_PROVE_LOCKING enabled, btw? I think I got the lock
> order correct but I don't have a NUMA machine to test it with here.

my x86_64 with CONFIG_PROVE_LOCKING don't output any warnings.

thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

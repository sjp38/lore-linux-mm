Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id A2FC56B0069
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 15:22:15 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2421381pbb.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 12:22:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120627181330.GN15811@google.com>
References: <20120619041154.GA28651@shangw>
	<20120619212059.GJ32733@google.com>
	<20120619212618.GK32733@google.com>
	<CAE9FiQVECyRBie-kgBETmqxPaMx24kUt1W07qAqoGD4vNus5xQ@mail.gmail.com>
	<20120621201728.GB4642@google.com>
	<CAE9FiQXubmnKHjnqOxVeoJknJZFNuStCcW=1XC6jLE7eznkTmg@mail.gmail.com>
	<20120622185113.GK4642@google.com>
	<CAE9FiQVV+WOWywnanrP7nX-wai=aXmQS1Dcvt4PxJg5XWynC+Q@mail.gmail.com>
	<20120622192919.GL4642@google.com>
	<CAE9FiQVeJYwpgHjAFp5Q7PazOjeDvN_etrnej987Rc94TjXfAg@mail.gmail.com>
	<20120627181330.GN15811@google.com>
Date: Wed, 27 Jun 2012 12:22:14 -0700
Message-ID: <CAE9FiQXk4abAzuKN8xiA5p5OJaG4UMzQR_Jzx2SsKOuUnKON_A@mail.gmail.com>
Subject: Re: Early boot panic on machine with lots of memory
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jun 27, 2012 at 11:13 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Yinghai.
>
> Sorry about the delay. =A0I'm in bug storm somehow. :(
>
> On Fri, Jun 22, 2012 at 07:14:43PM -0700, Yinghai Lu wrote:
>> On Fri, Jun 22, 2012 at 12:29 PM, Tejun Heo <tj@kernel.org> wrote:
>> > I wish we had a single call - say, memblock_die(), or whatever - so
>> > that there's a clear indication that memblock usage is done, but yeah
>> > maybe another day. =A0Will review the patch itself. =A0BTW, can't you =
post
>> > patches inline anymore? =A0Attaching is better than corrupt but is sti=
ll
>> > a bit annoying for review.
>>
>> please check the three patches:
>
> Heh, reviewing is cumbersome this way but here are my comments.
>
> * "[PATCH] memblock: free allocated memblock_reserved_regions later"
> =A0looks okay to me.

Good, this one should go to 3.5, right?


>
> * "[PATCH] memblock: Free allocated memblock.memory.regions" makes me
> =A0wonder whether it would be better to have something like the
> =A0following instead.
>
> =A0typedef void memblock_free_region_fn_t(unsigned long start, unsigned s=
ize);
>
> =A0void memblock_free_regions(memblock_free_region_fn_t free_fn)
> =A0{
> =A0 =A0 =A0 =A0/* call free_fn() on reserved and memory regions arrays */
> =A0 =A0 =A0 =A0/* clear both structures so that any further usage trigger=
s warning */
> =A0}

ok, will check it.

>
> * "memblock: Add checking about illegal using memblock".
> =A0Hmm... wouldn't it be better to be less explicit? =A0I think it's
> =A0adding too much opencoded identical checks. =A0Maybe implement a
> =A0common check & warning function?

yes.

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

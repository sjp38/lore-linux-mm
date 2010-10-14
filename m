Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A558A6B0167
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 08:10:09 -0400 (EDT)
Received: by bwz19 with SMTP id 19so464573bwz.14
        for <linux-mm@kvack.org>; Thu, 14 Oct 2010 05:10:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101014072421.GA13414@basil.fritz.box>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	<87sk0a1sq0.fsf@basil.nowhere.org>
	<20101014160217N.fujita.tomonori@lab.ntt.co.jp>
	<20101014072421.GA13414@basil.fritz.box>
Date: Thu, 14 Oct 2010 15:10:07 +0300
Message-ID: <AANLkTi=mGPjL0T33cuYbpKyc=a3d9XTCJqwBLFqVmWpm@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
From: Felipe Contreras <felipe.contreras@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Oct 14, 2010 at 10:24 AM, Andi Kleen <andi@firstfloor.org> wrote:
> On Thu, Oct 14, 2010 at 04:07:12PM +0900, FUJITA Tomonori wrote:
>> On Wed, 13 Oct 2010 09:01:43 +0200
>> Andi Kleen <andi@firstfloor.org> wrote:
>>
>> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
>> > >
>> > > What this wants to do:
>> > > =C2=A0 allocates a contiguous chunk of pages larger than MAX_ORDER.
>> > > =C2=A0 for device drivers (camera? etc..)
>> >
>> > I think to really move forward you need a concrete use case
>> > actually implemented in tree.
>>
>> As already pointed out, some embeded drivers need physcailly
>> contignous memory. Currenlty, they use hacky tricks (e.g. playing with
>> the boot memory allocators). There are several proposals for this like
>
> Are any of those in mainline?

drivers/video/omap/

--=20
Felipe Contreras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

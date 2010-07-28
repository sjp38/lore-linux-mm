Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 339CB6B024D
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 00:43:18 -0400 (EDT)
Received: by ywg8 with SMTP id 8so930169ywg.14
        for <linux-mm@kvack.org>; Tue, 27 Jul 2010 21:43:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100728085458C.fujita.tomonori@lab.ntt.co.jp>
References: <20100727091459.GA11134@lst.de> <20100727133956.GA7347@redhat.com>
	<20100727140947.GA25106@lst.de> <20100728085458C.fujita.tomonori@lab.ntt.co.jp>
From: Kay Sievers <kay.sievers@vrfy.org>
Date: Wed, 28 Jul 2010 06:42:59 +0200
Message-ID: <AANLkTi=azx1FvV9Hm8dVQH95LJK6T20bTBqYVSp0RqKH@mail.gmail.com>
Subject: Re: struct backing_dev - purpose and life time rules
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: hch@lst.de, vgoyal@redhat.com, jaxboe@fusionio.com, peterz@infradead.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 28, 2010 at 01:55, FUJITA Tomonori
<fujita.tomonori@lab.ntt.co.jp> wrote:
> Not a comment on the original topic,
>
> On Tue, 27 Jul 2010 16:09:47 +0200
> Christoph Hellwig <hch@lst.de> wrote:
>
>> On Tue, Jul 27, 2010 at 09:39:56AM -0400, Vivek Goyal wrote:
>> > How can I do it better?
>> >
>> > I needed a unique identifier with which user can work in terms of
>> > specifying weights to devices and in terms of understanding what stats
>> > mean. Device major/minor number looked like a obivious choice.
>> >
>> > I was looking for how to determine what is the major/minor number of disk
>> > request queue is associated with and I could use bdi to do that.
>>
>> The problem is that a queue can be shared between multiple gendisks,
>
> Is anyone still doing this?
>
> I thought that everyone agreed that this was wrong. Such users (like
> MTD) were fixed.

I think it was MTD, which is fixed, and floppy, which is still the way it was.

Kay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

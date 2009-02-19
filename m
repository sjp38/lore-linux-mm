Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C49DB6B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 07:12:50 -0500 (EST)
Received: by wa-out-1112.google.com with SMTP id k22so205541waf.22
        for <linux-mm@kvack.org>; Thu, 19 Feb 2009 04:12:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1235034817.29813.6.camel@penberg-laptop>
References: <499BE7F8.80901@csr.com> <1234954488.24030.46.camel@penberg-laptop>
	 <20090219101336.9556.A69D9226@jp.fujitsu.com>
	 <1235034817.29813.6.camel@penberg-laptop>
Date: Thu, 19 Feb 2009 21:12:49 +0900
Message-ID: <2f11576a0902190412m5b473a39o8b8fffa3f58c83d8@mail.gmail.com>
Subject: Re: [patch 1/7] slab: introduce kzfree()
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Vrabel <david.vrabel@csr.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

2009/2/19 Pekka Enberg <penberg@cs.helsinki.fi>:
> On Wed, 2009-02-18 at 10:50 +0000, David Vrabel wrote:
>> > > Johannes Weiner wrote:
>> > > > +void kzfree(const void *p)
>> > >
>> > > Shouldn't this be void * since it writes to the memory?
>> >
>> > No. kfree() writes to the memory as well to update freelists, poisoning
>> > and such so kzfree() is not at all different from it.
>
> On Thu, 2009-02-19 at 10:22 +0900, KOSAKI Motohiro wrote:
>> I don't think so. It's debetable thing.
>>
>> poisonig is transparent feature from caller.
>> but the caller of kzfree() know to fill memory and it should know.
>
> Debatable, sure, but doesn't seem like a big enough reason to make
> kzfree() differ from kfree().

Sure.
ok, I don't oppse this :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

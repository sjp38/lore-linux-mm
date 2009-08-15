Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3FDA86B004F
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 20:19:34 -0400 (EDT)
Received: by yxe14 with SMTP id 14so2409509yxe.12
        for <linux-mm@kvack.org>; Fri, 14 Aug 2009 17:19:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090814234539.GE27148@parisc-linux.org>
References: <200908122007.43522.ngupta@vflare.org>
	 <20090813151312.GA13559@linux.intel.com>
	 <20090813162621.GB1915@phenom2.trippelsdorf.de>
	 <alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>
	 <87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>
	 <alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm>
	 <3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com>
	 <4A85E0DC.9040101@rtr.ca>
	 <f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com>
	 <20090814234539.GE27148@parisc-linux.org>
Date: Fri, 14 Aug 2009 18:19:39 -0600
Message-ID: <f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com>
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
	slot is freed)
From: Chris Worley <worleys@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Matthew Wilcox <matthew@wil.cx>
Cc: Mark Lord <liml@rtr.ca>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 14, 2009 at 5:45 PM, Matthew Wilcox<matthew@wil.cx> wrote:
> On Fri, Aug 14, 2009 at 05:21:32PM -0600, Chris Worley wrote:
>> Sooner is better than waiting to coalesce. =A0The longer an LBA is
>> inactive, the better for any management scheme. =A0If you wait until
>> it's reused, you might as well forgo the advantages of TRIM/UNMAP. =A0If
>> a the controller wants to coalesce, let it coalesce.
>
> I'm sorry, you're wrong. =A0There is a tradeoff point, and it's different
> for each drive model. =A0Sending down a steady stream of tiny TRIMs is
> going to give terrible performance.

Sounds like you might be using junk for a device?

For junk, a little coalescing may be warranted... like in the I/O
schedular, but no more than 100usecs wait before posting, or then you
effect high performing devices too.

Chris
>
> --
> Matthew Wilcox =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Intel O=
pen Source Technology Centre
> "Bill, look, we understand that you're interested in selling us this
> operating system, but compare it to ours. =A0We can't possibly take such
> a retrograde step."
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

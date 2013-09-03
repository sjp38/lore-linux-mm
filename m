Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 6445C6B0033
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 06:32:08 -0400 (EDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: ipc msg now works (was Re: ipc-msg broken again on 3.11-rc7?)
Date: Tue, 3 Sep 2013 10:32:04 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA230751416DC@IN01WEMBXA.internal.synopsys.com>
References: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
 <CA+icZUUn-r8iq6TVMAKmgJpQm4FhOE4b4QN_Yy=1L=0Up=rkBA@mail.gmail.com>
 <52205597.3090609@synopsys.com>
 <CA+icZUW=YXMC_2Qt=cYYz6w_fVW8TS4=Pvbx7BGtzjGt+31rLQ@mail.gmail.com>
 <C2D7FE5348E1B147BCA15975FBA230751411CB@IN01WEMBXA.internal.synopsys.com>
 <CALE5RAvaa4bb-9xAnBe07Yp2n+Nn4uGEgqpLrKMuOE8hhZv00Q@mail.gmail.com>
 <CAMJEocr1SgxQw0bEzB3Ti9bvRY74TE5y9e+PLUsAL1mJbK=-ew@mail.gmail.com>
 <CA+55aFy8tbBpac57fU4CN3jMDz46kCKT7+7GCpb18CscXuOnGA@mail.gmail.com>
 <C2D7FE5348E1B147BCA15975FBA230751413F4@IN01WEMBXA.internal.synopsys.com>
 <5224BCF6.2080401@colorfullife.com>
 <C2D7FE5348E1B147BCA15975FBA23075141642@IN01WEMBXA.internal.synopsys.com>
 <5225A466.2080303@colorfullife.com>
 <C2D7FE5348E1B147BCA15975FBA2307514165E@IN01WEMBXA.internal.synopsys.com>
 <5225AA8D.6080403@colorfullife.com>
 <C2D7FE5348E1B147BCA15975FBA2307514168F@IN01WEMBXA.internal.synopsys.com>
 <5225B716.3090708@colorfullife.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <dave.bueso@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Jonathan
 Gonzalez <jgonzalez@linets.cl>

On 09/03/2013 03:47 PM, Manfred Spraul wrote:=0A=
> Hi Vineet,=0A=
>=0A=
> On 09/03/2013 11:51 AM, Vineet Gupta wrote:=0A=
>> On 09/03/2013 02:53 PM, Manfred Spraul wrote:=0A=
>>> The access to msq->q_cbytes is not protected.=0A=
>>>=0A=
>>> Vineet, could you try to move the test for free space after ipc_lock?=
=0A=
>>> I.e. the lock must not get dropped between testing for free space and=
=0A=
>>> enqueueing the messages.=0A=
>> Hmm, the code movement is not trivial. I broke even the simplest of case=
s (patch=0A=
>> attached). This includes the additional change which Linus/Davidlohr had=
 asked for.=0A=
> The attached patch should work. Could you try it?=0A=
>=0A=
=0A=
Yes this did the trick, now the default config of 100k iterations + 16 proc=
esses=0A=
runs to completion.=0A=
=0A=
Thx,=0A=
-Vineet=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 52EFF6B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 03:35:02 -0400 (EDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: ipc-msg broken again on 3.11-rc7?
Date: Tue, 3 Sep 2013 07:34:53 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA2307514160B@IN01WEMBXA.internal.synopsys.com>
References: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
	<1372192414.1888.8.camel@buesod1.americas.hpqcorp.net>
	<CA+icZUXgOd=URJBH5MGAZKdvdkMpFt+5mRxtzuDzq_vFHpoc2A@mail.gmail.com>
	<1372202983.1888.22.camel@buesod1.americas.hpqcorp.net>
	<521DE5D7.4040305@synopsys.com>
	<CA+icZUUrZG8pYqKcHY3DcYAuuw=vbdUvs6ZXDq5meBMjj6suFg@mail.gmail.com>
	<C2D7FE5348E1B147BCA15975FBA23075140FA3@IN01WEMBXA.internal.synopsys.com>
	<CA+icZUUn-r8iq6TVMAKmgJpQm4FhOE4b4QN_Yy=1L=0Up=rkBA@mail.gmail.com>
	<52205597.3090609@synopsys.com>
	<CA+icZUW=YXMC_2Qt=cYYz6w_fVW8TS4=Pvbx7BGtzjGt+31rLQ@mail.gmail.com>
	<C2D7FE5348E1B147BCA15975FBA230751411CB@IN01WEMBXA.internal.synopsys.com>
	<CALE5RAvaa4bb-9xAnBe07Yp2n+Nn4uGEgqpLrKMuOE8hhZv00Q@mail.gmail.com>
	<CAMJEocr1SgxQw0bEzB3Ti9bvRY74TE5y9e+PLUsAL1mJbK=-ew@mail.gmail.com>
	<CA+55aFy8tbBpac57fU4CN3jMDz46kCKT7+7GCpb18CscXuOnGA@mail.gmail.com>
	<C2D7FE5348E1B147BCA15975FBA230751413F4@IN01WEMBXA.internal.synopsys.com>
	<5224BCF6.2080401@colorfullife.com>
 <CA+icZUVc6fhW+TTB56x68LooS8DqhA8n3CQzgKkXQmbyH+ryUQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "sedat.dilek@gmail.com" <sedat.dilek@gmail.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <dave.bueso@gmail.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen
 Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Jonathan Gonzalez <jgonzalez@linets.cl>

On 09/03/2013 12:46 PM, Sedat Dilek wrote:=0A=
> Just FYI:=0A=
>=0A=
> Linux Testing Project (LTP) will do a new release in the 1st September we=
ek.=0A=
> Some IPC test-suites were reworked.=0A=
> Manfred can you look at them ("...msgctl08 uses one queue for each=0A=
> thread pair.").=0A=
> ( Might be worth to throw some words at the LTP mailing-list (that=0A=
> test-case is not ideal, etc.)? )=0A=
>=0A=
=0A=
Well we had a userspace test working before (3.10) and now it won't. In Lin=
ux=0A=
world that is not something we do in general - although there could be exce=
ptions=0A=
because the test is not idea etc - anyways not my call !=0A=
=0A=
However assuming we are going ahead with debugging this - can you please co=
nfirm=0A=
whether you see the issue on x86 as well as I have not tested that ? I vagu=
ely=0A=
remember one of your earlier posts suggested you did=0A=
=0A=
Thx,=0A=
-Vineet=0A=
=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

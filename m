Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 5134F6B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 04:46:46 -0400 (EDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: ipc-msg broken again on 3.11-rc7?
Date: Fri, 30 Aug 2013 08:46:39 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA230751411CB@IN01WEMBXA.internal.synopsys.com>
References: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
 <CA+icZUVbUD1tUa_ORtn_ZZebpp3gXXHGAcNe0NdYPXPMPoABuA@mail.gmail.com>
 <1372192414.1888.8.camel@buesod1.americas.hpqcorp.net>
 <CA+icZUXgOd=URJBH5MGAZKdvdkMpFt+5mRxtzuDzq_vFHpoc2A@mail.gmail.com>
 <1372202983.1888.22.camel@buesod1.americas.hpqcorp.net>
 <521DE5D7.4040305@synopsys.com>
 <CA+icZUUrZG8pYqKcHY3DcYAuuw=vbdUvs6ZXDq5meBMjj6suFg@mail.gmail.com>
 <C2D7FE5348E1B147BCA15975FBA23075140FA3@IN01WEMBXA.internal.synopsys.com>
 <CA+icZUUn-r8iq6TVMAKmgJpQm4FhOE4b4QN_Yy=1L=0Up=rkBA@mail.gmail.com>
 <52205597.3090609@synopsys.com>
 <CA+icZUW=YXMC_2Qt=cYYz6w_fVW8TS4=Pvbx7BGtzjGt+31rLQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "sedat.dilek@gmail.com" <sedat.dilek@gmail.com>
Cc: linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Manfred
 Spraul <manfred@colorfullife.com>, Jonathan Gonzalez <jgonzalez@linets.cl>

On 08/30/2013 01:57 PM, Sedat Dilek wrote:=0A=
> On Fri, Aug 30, 2013 at 10:19 AM, Vineet Gupta <vineetg76@gmail.com> wrot=
e:=0A=
>> Ping ?=0A=
>>=0A=
>> It seems 3.11 is pretty close to releasing but we stil have LTP msgctl08=
 causing a=0A=
>> hang (atleast on ARC) for both linux-next 20130829 as well as Linus tree=
.=0A=
>>=0A=
>> So far, I haven't seemed to have drawn attention of people involved.=0A=
>>=0A=
> =0A=
> Hi Vineet,=0A=
> =0A=
> I remember fakeroot was an another good test-case for me to test this=0A=
> IPC breakage.=0A=
> Attached is my build-script for Linux-next (tested with Debian/Ubuntu).=
=0A=
> ( Cannot say if you can play with it in your environment. )=0A=
=0A=
Hi Sedat,=0A=
=0A=
I have a simpler buildroot based rootfs (initramfs based) and LTP is run of=
f of=0A=
NFS, although running of a local storage doesn't make a difference.=0A=
=0A=
For me msgctl08 standalone (w/o hassle of running full LTP) is enough to tr=
igger=0A=
it consistently.=0A=
=0A=
P.S. sorry my sender address kept flipping - mailer was broken !=0A=
=0A=
-Vineet=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 20A9E6B025F
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 17:06:33 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id pp5so1951184pac.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 14:06:33 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id gc6si2368423pab.18.2016.07.26.14.06.32
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 14:06:32 -0700 (PDT)
From: "Roberts, William C" <william.c.roberts@intel.com>
Subject: RE: [PATCH] [RFC] Introduce mmap randomization
Date: Tue, 26 Jul 2016 21:06:30 +0000
Message-ID: <476DC76E7D1DF2438D32BFADF679FC5601260068@ORSMSX103.amr.corp.intel.com>
References: <1469557346-5534-1-git-send-email-william.c.roberts@intel.com>
 <1469557346-5534-2-git-send-email-william.c.roberts@intel.com>
 <20160726200309.GJ4541@io.lakedaemon.net>
 <476DC76E7D1DF2438D32BFADF679FC560125F29C@ORSMSX103.amr.corp.intel.com>
 <20160726205944.GM4541@io.lakedaemon.net>
In-Reply-To: <20160726205944.GM4541@io.lakedaemon.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "keescook@chromium.org" <keescook@chromium.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "nnk@google.com" <nnk@google.com>, "jeffv@google.com" <jeffv@google.com>, "salyzyn@android.com" <salyzyn@android.com>, "dcashman@android.com" <dcashman@android.com>



> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Jason Cooper
> Sent: Tuesday, July 26, 2016 2:00 PM
> To: Roberts, William C <william.c.roberts@intel.com>
> Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; kernel-
> hardening@lists.openwall.com; akpm@linux-foundation.org;
> keescook@chromium.org; gregkh@linuxfoundation.org; nnk@google.com;
> jeffv@google.com; salyzyn@android.com; dcashman@android.com
> Subject: Re: [PATCH] [RFC] Introduce mmap randomization
>=20
> Hi William,
>=20
> On Tue, Jul 26, 2016 at 08:13:23PM +0000, Roberts, William C wrote:
> > > > From: Jason Cooper [mailto:jason@lakedaemon.net] On Tue, Jul 26,
> > > > 2016 at 11:22:26AM -0700, william.c.roberts@intel.com wrote:
> > > > > Performance Measurements:
> > > > > Using strace with -T option and filtering for mmap on the
> > > > > program ls shows a slowdown of approximate 3.7%
> > > >
> > > > I think it would be helpful to show the effect on the resulting obj=
ect code.
> > >
> > > Do you mean the maps of the process? I have some captures for
> > > whoopsie on my Ubuntu system I can share.
>=20
> No, I mean changes to mm/mmap.o.

Sure I can post the objdump of that, do you just want a diff of old vs new?

>=20
> > > One thing I didn't make clear in my commit message is why this is
> > > good. Right now, if you know An address within in a process, you
> > > know all offsets done with mmap(). For instance, an offset To libX
> > > can yield libY by adding/subtracting an offset. This is meant to
> > > make rops a bit harder, or In general any mapping offset mmore diffic=
ult to
> find/guess.
>=20
> Are you able to quantify how many bits of entropy you're imposing on the
> attacker?  Is this a chair in the hallway or a significant increase in th=
e chances of
> crashing the program before finding the desired address?

I'd likely need to take a small sample of programs and examine them, especi=
ally considering
That as gaps are harder to find, it forces the randomization down and rando=
mization can
Be directly altered with length on mmap(), versus randomize_addr() which di=
dn't have this
restriction but OOM'd do to fragmented easier.

>=20
> thx,
>=20
> Jason.
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in the body to
> majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

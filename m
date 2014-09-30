Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id A00C86B0038
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 15:33:11 -0400 (EDT)
Received: by mail-yh0-f53.google.com with SMTP id b6so1318123yha.12
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 12:33:11 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id 67si8313625yhi.4.2014.09.30.12.33.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 30 Sep 2014 12:33:11 -0700 (PDT)
From: "Zuckerman, Boris" <borisz@hp.com>
Subject: RE: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
Date: Tue, 30 Sep 2014 19:31:55 +0000
Message-ID: <4C30833E5CDF444D84D942543DF65BDA6E047CAE@G4W3303.americas.hpqcorp.net>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <15705.1412070301@turing-police.cc.vt.edu> <20140930144854.GA5098@wil.cx>
 <123795.1412088827@turing-police.cc.vt.edu> <20140930160841.GB5098@wil.cx>
 <4C30833E5CDF444D84D942543DF65BDA6E047B9B@G4W3303.americas.hpqcorp.net>
 <20140930192428.GF5098@wil.cx>
In-Reply-To: <20140930192428.GF5098@wil.cx>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: "Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

I am trying to refocus this thread from a particular issue to more generic =
needs...

Regards, Boris

> -----Original Message-----
> From: Matthew Wilcox [mailto:willy@linux.intel.com]
> Sent: Tuesday, September 30, 2014 3:24 PM
> To: Zuckerman, Boris
> Cc: Matthew Wilcox; Valdis.Kletnieks@vt.edu; Matthew Wilcox; linux-
> fsdevel@vger.kernel.org; linux-mm@kvack.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
>=20
> On Tue, Sep 30, 2014 at 05:10:26PM +0000, Zuckerman, Boris wrote:
> > >
> > > The more I think about this, the more I think this is a bad idea.
> > > When you have a file open with O_DIRECT, your I/O has to be done in
> > > 512-byte multiples, and it has to be aligned to 512-byte boundaries
> > > in memory.  If an unsuspecting application has O_DIRECT forced on
> > > it, it isn't going to know to do that, and so all its I/Os will fail.
> > > It'll also be horribly inefficient if a program has the file mmaped.
> > >
> > > What problem are you really trying to solve?  Some big files hogging =
the page
> cache?
> > > --
> >
> > Page cache? As another copy in RAM?
> > NV_DIMMs may be viewed as a caching device. This caching can be impleme=
nted on
> the level of NV block/offset or may have some hints from FS and applicati=
ons.
> Temporary files is one example. They may not need to hit NV domain ever. =
Some
> transactional journals or DB files is another example. They may stay in R=
AM until power
> off.
>=20
> Boris, you're confused.  Valdis is trying to solve an unrelated problem (=
and hopes my
> DAX patches will do it for him).  I'm explaining to him why what he wants=
 to do is a bad
> idea.  This tangent is unrelated to NV-DIMMs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

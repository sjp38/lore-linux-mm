Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 67CE26B003A
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 13:11:41 -0400 (EDT)
Received: by mail-yk0-f170.google.com with SMTP id 20so1142895yks.29
        for <linux-mm@kvack.org>; Tue, 30 Sep 2014 10:11:41 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id v23si16517776yha.104.2014.09.30.10.11.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 30 Sep 2014 10:11:40 -0700 (PDT)
From: "Zuckerman, Boris" <borisz@hp.com>
Subject: RE: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
Date: Tue, 30 Sep 2014 17:10:26 +0000
Message-ID: <4C30833E5CDF444D84D942543DF65BDA6E047B9B@G4W3303.americas.hpqcorp.net>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <15705.1412070301@turing-police.cc.vt.edu> <20140930144854.GA5098@wil.cx>
 <123795.1412088827@turing-police.cc.vt.edu> <20140930160841.GB5098@wil.cx>
In-Reply-To: <20140930160841.GB5098@wil.cx>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>, "Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

>=20
> The more I think about this, the more I think this is a bad idea.
> When you have a file open with O_DIRECT, your I/O has to be done in 512-b=
yte
> multiples, and it has to be aligned to 512-byte boundaries in memory.  If=
 an
> unsuspecting application has O_DIRECT forced on it, it isn't going to kno=
w to do that,
> and so all its I/Os will fail.
> It'll also be horribly inefficient if a program has the file mmaped.
>=20
> What problem are you really trying to solve?  Some big files hogging the =
page cache?
> --

Page cache? As another copy in RAM?=20
NV_DIMMs may be viewed as a caching device. This caching can be implemented=
 on the level of NV block/offset or may have some hints from FS and applica=
tions. Temporary files is one example. They may not need to hit NV domain e=
ver. Some transactional journals or DB files is another example. They may s=
tay in RAM until power off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

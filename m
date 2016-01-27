Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 624006B0253
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 20:26:54 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id p187so116338803oia.2
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 17:26:54 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id h8si3495172oej.49.2016.01.26.17.26.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 17:26:53 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm/madvise: pass return code of memory_failure() to
 userspace
Date: Wed, 27 Jan 2016 01:26:20 +0000
Message-ID: <20160127012618.GA14613@hori1.linux.bs1.fc.nec.co.jp>
References: <1453451277-20979-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160126152758.0638a764ba99ab215c44977c@linux-foundation.org>
In-Reply-To: <20160126152758.0638a764ba99ab215c44977c@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <A76D7091E758CD4A87A77E5570E807E3@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chen Gong <gong.chen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Jan 26, 2016 at 03:27:58PM -0800, Andrew Morton wrote:
> On Fri, 22 Jan 2016 17:27:57 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
.com> wrote:
>=20
> > Currently the return value of memory_failure() is not passed to userspa=
ce, which
> > is inconvenient for test programs that want to know the result of error=
 handling.
> > So let's return it to the caller as we already do in MADV_SOFT_OFFLINE =
case.
>=20
> I updated this to mention that it's for madvise(MADV_HWPOISON):
>=20
> : Currently the return value of memory_failure() is not passed to userspa=
ce
> : when madvise(MADV_HWPOISON) is used.  This is inconvenient for test
> : programs that want to know the result of error handling.  So let's retu=
rn
> : it to the caller as we already do in the MADV_SOFT_OFFLINE case.

Thank you.

> btw, MADV_SOFT_OFFLINE and MADV_HWPOISON are not documented in that
> comment block over sys_madvise().  Fixy please?  You might want to
> check that no other MADV_foo values have been omitted.

OK, I posted the fix patch just now, which also updates about some other
madvices.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

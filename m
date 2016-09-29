Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3984328024D
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 04:27:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 21so141626431pfy.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 01:27:00 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id wj1si13257112pab.71.2016.09.29.01.26.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 01:26:59 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1 00/12] THP migration support
Date: Thu, 29 Sep 2016 08:25:30 +0000
Message-ID: <20160929082529.GA8389@hori1.linux.bs1.fc.nec.co.jp>
References: <20160926152234.14809-1-zi.yan@sent.com>
 <A0AA1E30-A897-4A48-9972-9BE1813AA57C@sent.com>
In-Reply-To: <A0AA1E30-A897-4A48-9972-9BE1813AA57C@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6DE90365CD60E44D864B4464C949ECBF@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Hi Yan,

On Mon, Sep 26, 2016 at 11:38:05AM -0400, Zi Yan wrote:
> On 26 Sep 2016, at 11:22, zi.yan@sent.com wrote:
>=20
> > From: Zi Yan <zi.yan@cs.rutgers.edu>
> >
> > Hi all,
> >
> > This patchset is based on Naoya Horiguchi's page migration enchancement
> > for thp patchset with additional IBM ppc64 support. And I rebase it
> > on the latest upstream commit.

Thanks for helping,

I think that you seem to do some testing with these patches on powerpc,
which shows that thp migration can be enabled relatively easily for
non-x86_64. This is a good news to me.

And I apology for my slow development over this patchset.
My previous post was about 5 months ago, and I've not done ver.2 due to
many interruptions. Someone also privately asked me about the progress
of this work, so I promised ver.2 will be posted in a few weeks.
Your patch 12/12 will come with it.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

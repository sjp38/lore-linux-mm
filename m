Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89E026B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 10:41:28 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p64so103221954pfb.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 07:41:28 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id l24si3731145pfa.120.2016.07.20.07.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 07:41:27 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id h186so3599187pfg.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 07:41:27 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
In-Reply-To: <20160711143342.GN1811@dhcp22.suse.cz>
Date: Wed, 20 Jul 2016 20:11:09 +0530
Content-Transfer-Encoding: quoted-printable
Message-Id: <F072D3E2-0514-4A25-868E-2104610EC14A@gmail.com>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com> <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com> <20160711063730.GA5284@dhcp22.suse.cz> <1468246371.13253.63.camel@surriel.com> <20160711143342.GN1811@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com


> On Jul 11, 2016, at 8:03 PM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Mon 11-07-16 10:12:51, Rik van Riel wrote:
>>=20
>> What mechanism do you have in mind for obtaining the name,
>> Michal?
>=20
> Not sure whether tracing infrastructure allows printk like %ps. If not
> then it doesn't sound too hard to add.

It does allow %ps. Currently what is being printed is the function =
symbol=20
of the callback using %pF. I=E2=80=99d like to know why %pF is used =
instead of
%ps in this case.

Michal, just to make sure I understand you correctly, do you mean that =
we
could infer the names of the shrinkers by looking at the names of their =
callbacks?

Janani.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D99986B02FC
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 06:35:52 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id k186so281777ith.1
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 03:35:52 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 82sor2725272ite.139.2017.11.28.03.35.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 03:35:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171120154648.6c2f96804c4c1668bd8d572a@linux-foundation.org>
References: <CGME20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1>
 <20171018104832epcms5p1b2232e2236258de3d03d1344dde9fce0@epcms5p1> <20171120154648.6c2f96804c4c1668bd8d572a@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 28 Nov 2017 06:35:10 -0500
Message-ID: <CALZtONA1R8HyODqUP8Z-0yxvRAsV=Zo8OD2PQT3HwWWmqE6Hig@mail.gmail.com>
Subject: Re: [PATCH] zswap: Same-filled pages handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Srividya Desireddy <srividya.dr@samsung.com>, "sjenning@redhat.com" <sjenning@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, RAJIB BASU <rajib.basu@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

On Mon, Nov 20, 2017 at 6:46 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> On Wed, 18 Oct 2017 10:48:32 +0000 Srividya Desireddy <srividya.dr@samsung.com> wrote:
>
> > +/* Enable/disable handling same-value filled pages (enabled by default) */
> > +static bool zswap_same_filled_pages_enabled = true;
> > +module_param_named(same_filled_pages_enabled, zswap_same_filled_pages_enabled,
> > +                bool, 0644);
>
> Do we actually need this?  Being able to disable the new feature shows
> a certain lack of confidence ;) I guess we can remove it later as that
> confidence grows.

No, it's not absolutely needed to have the param to enable/disable the
feature, but my concern is around how many pages actually benefit from
this, since it adds some overhead to check every page - the usefulness
of the feature depends entirely on the system workload.  So having a
way to disable it is helpful, for use cases that know it won't benefit
them.

>
> Please send a patch to document this parameter in
> Documentation/vm/zswap.txt.  And if you have time, please check that
> the rest of that file is up-to-date?

Srividya, can you send a patch to doc this feature please.

I'll check the rest of the file is correct.

>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

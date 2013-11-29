Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 84FC26B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 21:06:32 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so13568649pbc.12
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 18:06:32 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id dn2si7121467pbc.33.2013.11.28.18.06.30
        for <linux-mm@kvack.org>;
        Thu, 28 Nov 2013 18:06:31 -0800 (PST)
From: "Ma, Xindong" <xindong.ma@intel.com>
Subject: RE: [PATCH] Fix race between oom kill and task exit
Date: Fri, 29 Nov 2013 02:06:25 +0000
Message-ID: <3917C05D9F83184EAA45CE249FF1B1DD025310D2@SHSMSX103.ccr.corp.intel.com>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com>
 <20131128063505.GN3556@cmpxchg.org>
 <CAJ75kXZXxCMgf8=pghUWf=W9EKf3Z4nzKKy=CAn+7keVF_DCRA@mail.gmail.com>
 <20131128120018.GL2761@dhcp22.suse.cz> <20131128183830.GD20740@redhat.com>
In-Reply-To: <20131128183830.GD20740@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@suse.cz>
Cc: William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "Tu, Xiaobing" <xiaobing.tu@intel.com>, azurIt <azurit@pobox.sk>, Sameer Nanda <snanda@chromium.org>

> From: Oleg Nesterov [mailto:oleg@redhat.com]
> Sent: Friday, November 29, 2013 2:39 AM
> To: Michal Hocko
> Cc: William Dauchy; Johannes Weiner; Ma, Xindong;
> akpm@linux-foundation.org; rientjes@google.com; rusty@rustcorp.com.au;
> linux-mm@kvack.org; linux-kernel@vger.kernel.org; Peter Zijlstra;
> gregkh@linuxfoundation.org; Tu, Xiaobing; azurIt; Sameer Nanda
> Subject: Re: [PATCH] Fix race between oom kill and task exit
>=20
> On 11/28, Michal Hocko wrote:
> >
> > They are both trying to solve the same issue. Neither of them is
> > optimal unfortunately.
>=20
> yes, but this one doesn't look right.
>=20
> > Oleg said he would look into this and I have seen some patches but
> > didn't geto check them.
>=20
> Only preparations so far.
>=20
> Oleg.

I was not aware there's a long story for this issue. I hit this issue a lot=
 of times during stress test and root caused it. After applying my patch, I=
 did extensive test on 5 machines for a long time, it does not reproduced a=
nymore so I submitted the patch.

I will do more research on this issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

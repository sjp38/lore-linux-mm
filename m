Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 97E576B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 21:08:31 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so13522525pbb.31
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 18:08:31 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id v7si38234079pbi.338.2013.11.28.18.08.29
        for <linux-mm@kvack.org>;
        Thu, 28 Nov 2013 18:08:30 -0800 (PST)
From: "Tu, Xiaobing" <xiaobing.tu@intel.com>
Subject: RE: [PATCH] Fix race between oom kill and task exit
Date: Fri, 29 Nov 2013 02:08:23 +0000
Message-ID: <EE928378561BF1449699C96571234A741231A21A@SHSMSX103.ccr.corp.intel.com>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com>
 <20131128063505.GN3556@cmpxchg.org>
 <CAJ75kXZXxCMgf8=pghUWf=W9EKf3Z4nzKKy=CAn+7keVF_DCRA@mail.gmail.com>
 <20131128120018.GL2761@dhcp22.suse.cz> <20131128183830.GD20740@redhat.com>
 <3917C05D9F83184EAA45CE249FF1B1DD025310D2@SHSMSX103.ccr.corp.intel.com>
In-Reply-To: <3917C05D9F83184EAA45CE249FF1B1DD025310D2@SHSMSX103.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ma, Xindong" <xindong.ma@intel.com>, Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@suse.cz>
Cc: William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, azurIt <azurit@pobox.sk>, Sameer Nanda <snanda@chromium.org>

We will do more stress test in more machine at the same time

-----Original Message-----
From: Ma, Xindong=20
Sent: Friday, November 29, 2013 10:06 AM
To: Oleg Nesterov; Michal Hocko
Cc: William Dauchy; Johannes Weiner; akpm@linux-foundation.org; rientjes@go=
ogle.com; rusty@rustcorp.com.au; linux-mm@kvack.org; linux-kernel@vger.kern=
el.org; Peter Zijlstra; gregkh@linuxfoundation.org; Tu, Xiaobing; azurIt; S=
ameer Nanda
Subject: RE: [PATCH] Fix race between oom kill and task exit

> From: Oleg Nesterov [mailto:oleg@redhat.com]
> Sent: Friday, November 29, 2013 2:39 AM
> To: Michal Hocko
> Cc: William Dauchy; Johannes Weiner; Ma, Xindong;=20
> akpm@linux-foundation.org; rientjes@google.com; rusty@rustcorp.com.au;=20
> linux-mm@kvack.org; linux-kernel@vger.kernel.org; Peter Zijlstra;=20
> gregkh@linuxfoundation.org; Tu, Xiaobing; azurIt; Sameer Nanda
> Subject: Re: [PATCH] Fix race between oom kill and task exit
>=20
> On 11/28, Michal Hocko wrote:
> >
> > They are both trying to solve the same issue. Neither of them is=20
> > optimal unfortunately.
>=20
> yes, but this one doesn't look right.
>=20
> > Oleg said he would look into this and I have seen some patches but=20
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

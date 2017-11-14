Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B66436B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 02:06:38 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b189so2758540wmd.5
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 23:06:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x1si1050609edc.447.2017.11.13.23.06.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Nov 2017 23:06:37 -0800 (PST)
Date: Tue, 14 Nov 2017 08:06:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Message-ID: <20171114070634.zoh75rakg57uhd3j@dhcp22.suse.cz>
References: <AM3PR04MB14892A9D6D2FBCE21B8C1F0FF12B0@AM3PR04MB1489.eurprd04.prod.outlook.com>
 <AM3PR04MB14895AE080F9F21E98045D99F12B0@AM3PR04MB1489.eurprd04.prod.outlook.com>
 <20171113110232.ivd6l52y7j2q2iaq@dhcp22.suse.cz>
 <AM3PR04MB1489AD776D0539665B108A04F1280@AM3PR04MB1489.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AM3PR04MB1489AD776D0539665B108A04F1280@AM3PR04MB1489.eurprd04.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ran Wang <ran.wang_1@nxp.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Leo Li <leoyang.li@nxp.com>, Xiaobo Xie <xiaobo.xie@nxp.com>

On Tue 14-11-17 06:10:00, Ran Wang wrote:
[...]
> > > This drop cause DWC3 USB controller fail on initialization with
> > > Layerscaper processors (such as LS1043A) as below:
> > >
> > > [    2.701437] xhci-hcd xhci-hcd.0.auto: new USB bus registered, assigned
> > bus number 1
> > > [    2.710949] cma: cma_alloc: alloc failed, req-size: 1 pages, ret: -16
> > > [    2.717411] xhci-hcd xhci-hcd.0.auto: can't setup: -12
> > > [    2.727940] xhci-hcd xhci-hcd.0.auto: USB bus 1 deregistered
> > > [    2.733607] xhci-hcd: probe of xhci-hcd.0.auto failed with error -12
> > > [    2.739978] xhci-hcd xhci-hcd.1.auto: xHCI Host Controller
> > >
> > > And I notice that someone also reported to you that DWC2 got affected
> > > recently, so do you have the solution now?
> > 
> > Yes. It should be in linux-next. Have a look at the following email
> > thread:
> > https://emea01.safelinks.protection.outlook.com/?url=http%3A%2F%2Flkml.
> > kernel.org%2Fr%2F20171104082500.qvzbb2kw4suo6cgy%40dhcp22.suse.cz&
> > data=02%7C01%7Cran.wang_1%40nxp.com%7C5e73c6a941fc4f1c10e708d52
> > a860c5b%7C686ea1d3bc2b4c6fa92cd99c5c301635%7C0%7C0%7C636461677
> > 583607877&sdata=zlRxJ4LZwOBsit5qRx9yFT5qfP54wZ0z6G1z%2Bcywf5g%3D
> > &reserved=0

I really have no idea where the above link came from because my email
had a reference to http://lkml.kernel.org/r/20171104082500.qvzbb2kw4suo6cgy@dhcp22.suse.cz
Has your email client modified the original email?

> Thanks for your info, although I fail to open the link you shared, but I got patch
> from my colleague and the issue got fix on my side, let you know, thanks.

Thanks for your testing anyway. Can I assume your Tested-by?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

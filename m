Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 060236B01F1
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 20:22:01 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o7P0PWQa029424
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:25:32 -0700
Received: from pvg13 (pvg13.prod.google.com [10.241.210.141])
	by wpaz5.hot.corp.google.com with ESMTP id o7P0PUPr016613
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:25:31 -0700
Received: by pvg13 with SMTP id 13so15090pvg.10
        for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:25:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100825091747.f6ea9e0e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
	<4C738B34.6070602@cn.fujitsu.com>
	<AANLkTi=HwPeWafzTBh66g37XxZouKicsemmnTE-Cvz=Y@mail.gmail.com>
	<20100825091747.f6ea9e0e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 24 Aug 2010 17:25:30 -0700
Message-ID: <AANLkTi=e9NfdQSTHk2DFEPWT3uVEnQAreCZPpRDFjxgC@mail.gmail.com>
Subject: Re: [PATCH 1/5] cgroup: ID notification call back
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 24, 2010 at 5:17 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> Hmm, then, should I remove it in the next version, or leave it as it is
> now and should be removed by another total clean up ?

I think these are two separate issues. A cleanup to remove the ss
parameters from the existing callback methods would be separate from
your proposed id callback, which I think is better done (as I
mentioned above) by passing the id to create()

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

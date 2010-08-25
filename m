Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D6C976B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 20:42:29 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o7P0k59Y015921
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:46:05 -0700
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by kpbe15.cbf.corp.google.com with ESMTP id o7P0k3i2023925
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:46:03 -0700
Received: by pwi10 with SMTP id 10so91361pwi.4
        for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:46:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100825093747.24085b28.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=imK6Px+JrdVupg2V3jtN9pgmEdWv=+aB1XKLY@mail.gmail.com>
	<20100825092010.cfe91b1a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikD3CFRPo7WvWwCnLQ+jzEs6rUk1sivYM3aRbGJ@mail.gmail.com>
	<20100825093747.24085b28.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 24 Aug 2010 17:46:03 -0700
Message-ID: <AANLkTi=KW_gxbmB14j5opSKL+-JFDFKO1YP6a7yvT8U5@mail.gmail.com>
Subject: Re: [PATCH 1/5] cgroup: ID notification call back
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 24, 2010 at 5:37 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> Ou...I'm sorry but I would like to use attach_id() for this time.
> Forgive me, above seems a big change.
> I'd like to write a series of patch to do above, later.
> At least, to do a trial.
>

Sure, for testing outside the tree. I don't think introducing new code
into mainline that's intentionally ugly and cutting corners is a good
idea.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

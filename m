Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F2C3E6B004F
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 20:41:09 -0500 (EST)
Received: from spaceape24.eur.corp.google.com (spaceape24.eur.corp.google.com [172.28.16.76])
	by smtp-out.google.com with ESMTP id n0K1f7eP024470
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 17:41:07 -0800
Received: from rv-out-0708.google.com (rvbf25.prod.google.com [10.140.82.25])
	by spaceape24.eur.corp.google.com with ESMTP id n0K1f2dw028187
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 17:41:03 -0800
Received: by rv-out-0708.google.com with SMTP id f25so2892395rvb.50
        for <linux-mm@kvack.org>; Mon, 19 Jan 2009 17:41:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090116120001.f37e1895.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090116120001.f37e1895.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 19 Jan 2009 17:41:02 -0800
Message-ID: <6599ad830901191741j4668f529s97ee6e896b0c011d@mail.gmail.com>
Subject: Re: [PATCH 2/4] cgroup:add css_is_populated
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 15, 2009 at 7:00 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Li-san, If you don't like this, could you give me an idea for
> "How to check cgroup is fully ready or not" ?
>
> BTW, why "we have a half filled direcotory - oh well" is allowed....

That's pretty much inherited from the original cpusets code. It
probably should be cleaned up, but unless the system is totally hosed
it seems pretty unlikely for creation of a few dentries to fail.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

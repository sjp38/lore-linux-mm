Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m1KA6s06012710
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 02:06:54 -0800
Received: from py-out-1112.google.com (pyia29.prod.google.com [10.34.253.29])
	by zps75.corp.google.com with ESMTP id m1KA6rNg031478
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 02:06:54 -0800
Received: by py-out-1112.google.com with SMTP id a29so2606723pyi.0
        for <linux-mm@kvack.org>; Wed, 20 Feb 2008 02:06:53 -0800 (PST)
Message-ID: <6599ad830802200206w23955c9cn26bf768e790a6161@mail.gmail.com>
Date: Wed, 20 Feb 2008 02:06:53 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <20080220.185821.61784723.taka@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	 <Pine.LNX.4.64.0802191449490.6254@blonde.site>
	 <47BBC15E.5070405@linux.vnet.ibm.com>
	 <20080220.185821.61784723.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Feb 20, 2008 1:58 AM, Hirokazu Takahashi <taka@valinux.co.jp> wrote:
> >
> > 1. Have a boot option to turn on/off the memory controller
>
> It will be much convenient if the memory controller can be turned on/off on
> demand. I think you can turn it off if there aren't any mem_cgroups except
> the root mem_cgroup,

Or possibly turned on when the memory controller is bound to a
non-default hierarchy, and off when it's unbound?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

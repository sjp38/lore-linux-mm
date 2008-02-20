Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m1KBiEbs026065
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 03:44:14 -0800
Received: from py-out-1112.google.com (pyhf31.prod.google.com [10.34.233.31])
	by zps36.corp.google.com with ESMTP id m1KBi93E014237
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 03:44:13 -0800
Received: by py-out-1112.google.com with SMTP id f31so2983483pyh.17
        for <linux-mm@kvack.org>; Wed, 20 Feb 2008 03:44:12 -0800 (PST)
Message-ID: <6599ad830802200344j55d493b2i36a4a962d50282f8@mail.gmail.com>
Date: Wed, 20 Feb 2008 03:44:12 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <47BC1055.3000304@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080220.185821.61784723.taka@valinux.co.jp>
	 <6599ad830802200206w23955c9cn26bf768e790a6161@mail.gmail.com>
	 <47BBFCC2.5020408@linux.vnet.ibm.com>
	 <6599ad830802200218t41c70455u5d008c605e8b9762@mail.gmail.com>
	 <47BC0704.9010603@linux.vnet.ibm.com>
	 <20080220202143.4cc2fc05.kamezawa.hiroyu@jp.fujitsu.com>
	 <47BC0C72.4080004@linux.vnet.ibm.com>
	 <20080220203208.f7b876ef.kamezawa.hiroyu@jp.fujitsu.com>
	 <47BC1055.3000304@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Feb 20, 2008 3:34 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > like..
> >    cgroup_subsys_disable_mask = ...
>
> I like this very much. This way, we get control over all controllers.
>

We'd want to do it by name, rather than by mask, since the ids depend
on what's compiled in to the kernel.

We could have a (possibly repeated) boot option such as
cgroup_disable=memory (or other subsystem). This would set a flag in
the appropriate subsystem indicating that it was disabled, and make
the subsystem not mountable, etc.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

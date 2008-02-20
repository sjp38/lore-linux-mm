Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m1KAIX4i017231
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 10:18:33 GMT
Received: from py-out-1112.google.com (pyef47.prod.google.com [10.34.157.47])
	by zps36.corp.google.com with ESMTP id m1KAGl1w014814
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 02:18:32 -0800
Received: by py-out-1112.google.com with SMTP id f47so2825632pye.8
        for <linux-mm@kvack.org>; Wed, 20 Feb 2008 02:18:32 -0800 (PST)
Message-ID: <6599ad830802200218t41c70455u5d008c605e8b9762@mail.gmail.com>
Date: Wed, 20 Feb 2008 02:18:31 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <47BBFCC2.5020408@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
	 <Pine.LNX.4.64.0802191449490.6254@blonde.site>
	 <47BBC15E.5070405@linux.vnet.ibm.com>
	 <20080220.185821.61784723.taka@valinux.co.jp>
	 <6599ad830802200206w23955c9cn26bf768e790a6161@mail.gmail.com>
	 <47BBFCC2.5020408@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Feb 20, 2008 2:11 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
> Dynamically turning on/off the memory controller, can/will lead to accounting
> issues and deficiencies, since the memory controller would now have no idea of
> how much memory has been allocated by which cgroup.
>

A cgroups subsystem can only be unbound from its hierarchy when there
are no child cgroups of the root cgroup in that hierarchy. So this
shouldn't be too much of a problem - when this transition occurs, all
tasks are in the same group, and no other groups exist.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m1KBfT1b000680
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 03:41:29 -0800
Received: from py-out-1112.google.com (pybu77.prod.google.com [10.34.97.77])
	by zps36.corp.google.com with ESMTP id m1KBfSNa012195
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 03:41:29 -0800
Received: by py-out-1112.google.com with SMTP id u77so2573258pyb.3
        for <linux-mm@kvack.org>; Wed, 20 Feb 2008 03:41:28 -0800 (PST)
Message-ID: <6599ad830802200341m1c8e8073h9b91f6daf6e01862@mail.gmail.com>
Date: Wed, 20 Feb 2008 03:41:28 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <47BC0C72.4080004@linux.vnet.ibm.com>
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
	 <6599ad830802200218t41c70455u5d008c605e8b9762@mail.gmail.com>
	 <47BC0704.9010603@linux.vnet.ibm.com>
	 <20080220202143.4cc2fc05.kamezawa.hiroyu@jp.fujitsu.com>
	 <47BC0C72.4080004@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Feb 20, 2008 3:18 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
> Kame, unbind->force_empty can work, but we can't force_empty the root cgroup.
> Even if we could, the code to deal with turning on/off the entire memory
> controller and accounting is likely to be very complex and probably racy.
>

How about just being able to turn it on, but not turn it off again?
i.e. at the first cgroups bind() event for the memory controller,
memory accounting is enabled.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

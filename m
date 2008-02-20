Date: Wed, 20 Feb 2008 20:32:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
Message-Id: <20080220203208.f7b876ef.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47BC0C72.4080004@linux.vnet.ibm.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, Hirokazu Takahashi <taka@valinux.co.jp>, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 16:48:10 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> Kame, unbind->force_empty can work, but we can't force_empty the root cgroup.
> Even if we could, the code to deal with turning on/off the entire memory
> controller and accounting is likely to be very complex and probably racy.
> 
Ok, just put it on my far-future-to-do-list.
(we have another things to do now ;)

But a boot option for turning off entire (memory) controller even if it is
configured will be a good thing.

like..
   cgroup_subsys_disable_mask = ...
or
   memory_controller=off|on

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

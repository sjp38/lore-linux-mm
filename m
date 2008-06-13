Date: Fri, 13 Jun 2008 09:41:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Message-Id: <20080613094100.b552079d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080613093436.ca1a6ded.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080612131748.GB8453@us.ibm.com>
	<20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110017t5ebeda78id1914d179a018422@mail.gmail.com>
	<20080611164544.94047336.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110104n99cdc7h80063e91d16bf0a5@mail.gmail.com>
	<20080611172714.018aa68c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110148v65df67f8ge0ccdd56c21c89e0@mail.gmail.com>
	<20080612140806.dc161c77.kamezawa.hiroyu@jp.fujitsu.com>
	<27043861.1213277688814.kamezawa.hiroyu@jp.fujitsu.com>
	<20080612210812.GA22948@us.ibm.com>
	<20080613093436.ca1a6ded.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Paul Menage <menage@google.com>, yamamoto@valinux.co.jp, nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jun 2008 09:34:36 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Thank you for kindly explanation. I'll take this into account. I confirmed
> memory resouce controller should not get tasks's cgroup directly from "task"
> and should get it from "mm->owner".
> 
And this means the whole thread group's memory related cgroup can be changed
when mm->owner is changed. I'm not sure this is not a problem but it seems
complex.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Fri, 13 Jun 2008 09:34:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Message-Id: <20080613093436.ca1a6ded.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080612210812.GA22948@us.ibm.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Paul Menage <menage@google.com>, yamamoto@valinux.co.jp, nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jun 2008 16:08:12 -0500
"Serge E. Hallyn" <serue@us.ibm.com> wrote:

> > Assume a thread group contains threadA, threadB, threadC.
> > 
> > I wanted to ask "Can threadA, and threadB, and threadC
> > be in different cgroups ? And if so, how ns cgroup handles it ?"
> > 
> > Maybe I don't understand ns cgroup.
> 
> In part yes, but nonetheless a very interesting question when it comes
> to composition of cgroups!
> 
> Yes, you can have threads in different cgroups.  The ns cgroup just
> tracks nsproxy unshares.  So if you run the attached program and look
> around, you'll see the first thread is in /cg/taskpid while the second
> one is in /cg/taskpid/secondthreadpid.
> 
> Clearly, composing this with a cgroup which needs to keep threads in the
> same cgroup becomes problematic!
> 
> Interesting :)
> 

Thank you for kindly explanation. I'll take this into account. I confirmed
memory resouce controller should not get tasks's cgroup directly from "task"
and should get it from "mm->owner".

Thank you.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

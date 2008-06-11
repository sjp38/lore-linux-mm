Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id m5B8mLie008133
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 09:48:22 +0100
Received: from an-out-0708.google.com (andd40.prod.google.com [10.100.30.40])
	by spaceape9.eur.corp.google.com with ESMTP id m5B8mKCA015132
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 09:48:21 +0100
Received: by an-out-0708.google.com with SMTP id d40so773184and.62
        for <linux-mm@kvack.org>; Wed, 11 Jun 2008 01:48:20 -0700 (PDT)
Message-ID: <6599ad830806110148v65df67f8ge0ccdd56c21c89e0@mail.gmail.com>
Date: Wed, 11 Jun 2008 01:48:20 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
In-Reply-To: <20080611172714.018aa68c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830806110017t5ebeda78id1914d179a018422@mail.gmail.com>
	 <20080611164544.94047336.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830806110104n99cdc7h80063e91d16bf0a5@mail.gmail.com>
	 <20080611172714.018aa68c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 11, 2008 at 1:27 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Sorry. try another sentense..
>
> I think cgroup itself is designed to be able to be used without middleware.

True, but it shouldn't be hostile to middleware, since I think that
automated use will be much more common. (And certainly if you count
the number of servers :-) )

> IOW, whether using middleware or not is the matter of users not of developpers.
> There will be a system that system admin controlles all and move tasks by hand.
> ex)...personal notebooks etc..
>

You think so? I think that at the very least users will be using tools
based around config scripts, rule engines and libcgroup, if not a
persistent daemon.

>> If the common mode for middleware starting a new cgroup is fork() /
>> move / exec() then after the fork(), the child will be sharing pages
>> with the main daemon process. So the move will pull all the daemon's
>> memory into the new cgroup
>>
> My patch (this patch) just moves Private Anon page to new cgroup. (of mapcount=1)

OK, well that makes it more reasonable regarding the above problem.
But I can still see problems if, say, a single thread moves into a new
cgroup, you move the entire memory. Perhaps you should only do so if
the mm->owner changes task?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 11 Jun 2008 17:27:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Message-Id: <20080611172714.018aa68c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830806110104n99cdc7h80063e91d16bf0a5@mail.gmail.com>
References: <20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110017t5ebeda78id1914d179a018422@mail.gmail.com>
	<20080611164544.94047336.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110104n99cdc7h80063e91d16bf0a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 01:04:14 -0700
"Paul Menage" <menage@google.com> wrote:

> An alternative way to support that would be to do nothing at move
> time, but provide a "pull_usage" control file that would slurp any
> pages in any mm in the cgroup into the cgroup.
> >> >
> >> > One reasone is that I think a typical usage of memory controller is
> >> > fork()->move->exec(). (by libcg ?) and exec() will flush the all usage.
> >>
> >> Exactly - this is a good reason *not* to implement move - because then
> >> you drag all the usage of the middleware daemon into the new cgroup.
> >>
> > Yes but this is one of the usage of cgroup. In general, system admin can
> > use this for limiting memory on his own decision.
> >
> 
> Sorry, your last sentence doesn't make sense to me in this context.
> 
Sorry. try another sentense..

I think cgroup itself is designed to be able to be used without middleware.
IOW, whether using middleware or not is the matter of users not of developpers.
There will be a system that system admin controlles all and move tasks by hand.
ex)...personal notebooks etc..

> If the common mode for middleware starting a new cgroup is fork() /
> move / exec() then after the fork(), the child will be sharing pages
> with the main daemon process. So the move will pull all the daemon's
> memory into the new cgroup
> 
My patch (this patch) just moves Private Anon page to new cgroup. (of mapcount=1)


> > yes. but, at first, I'll try no-rollback approach.
> > And can I move memory resource controller's subsys_id to the last for now ?
> >
> 
> That's probably fine for experimentation, but it wouldn't be something
> we'd want to commit to -mm or mainline.
> 


Hmm, I'd like to post a patch to add "rollback" to cgroup if I find it necessary.
My first purpose of this post is showing the problem and starting discussion.
Anyway, I will remove "RFC" only when I got enough number of Acks. 


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 11 Jun 2008 21:21:26 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
Message-Id: <20080611212126.317a95f7.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <484F8C76.4080300@linux.vnet.ibm.com>
References: <20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806110017t5ebeda78id1914d179a018422@mail.gmail.com>
	<484F8C76.4080300@linux.vnet.ibm.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 13:57:34 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

(snip)

> >>  2. Don't move any usage at task move. (current implementation.)
> >>    Pros.
> >>      - no complication in the code.
> >>    Cons.
> >>      - A task's usage is chareged to wrong cgroup.
> >>      - Not sure, but I believe the users don't want this.
> > 
> > I'd say stick with this unless there a strong arguments in favour of
> > changing, based on concrete needs.
> > 
> >> One reasone is that I think a typical usage of memory controller is
> >> fork()->move->exec(). (by libcg ?) and exec() will flush the all usage.
> > 
> > Exactly - this is a good reason *not* to implement move - because then
> > you drag all the usage of the middleware daemon into the new cgroup.
> > 
> 
> Yes. The other thing is that charges will eventually fade away. Please see the
> cgroup implementation of page_referenced() and mark_page_accessed(). The
> original group on memory pressure will drop pages that were left behind by a
> task that migrates. The new group will pick it up if referenced.
> 
Hum..
So, it seems that some kind of "Lazy Mode"(#3 of Kamezawa-san's)
has been implemented already.

But, one of the reason that I think usage should be moved
is to make the usage as accurate as possible, that is
the size of memory used by processes in the group at the moment.

I agree that statistics is not the purpose of memcg(and swap),
but, IMHO, it's useful feature of memcg.
Administrators can know how busy or idle each groups are by it.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

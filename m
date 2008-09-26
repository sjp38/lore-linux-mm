Date: Fri, 26 Sep 2008 18:21:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/12] memcg make root cgroup unlimited.
Message-Id: <20080926182122.c7c88a65.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48DCA01C.9020701@linux.vnet.ibm.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080925151543.ba307898.kamezawa.hiroyu@jp.fujitsu.com>
	<48DCA01C.9020701@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 14:11:00 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Make root cgroup of memory resource controller to have no limit.
> > 
> > By this, users cannot set limit to root group. This is for making root cgroup
> > as a kind of trash-can.
> > 
> > For accounting pages which has no owner, which are created by force_empty,
> > we need some cgroup with no_limit. A patch for rewriting force_empty will
> > will follow this one.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This is an ABI change (although not too many people might be using it, I wonder
> if we should add memory.features (a set of flags and let users enable them and
> provide good defaults), like sched features.
> 
I think "feature" flag is complicated, at this stage.
We'll add more features and not settled yet.

Hmm, if you don't like this,
calling try_to_free_page() at force_empty() instead of move_account() ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

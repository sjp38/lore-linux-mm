Date: Wed, 4 Jun 2008 18:31:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/2] memcg: hierarchy support (v3)
Message-Id: <20080604183157.d6d1289d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830806040215j4f49483bnfa474eb27120a5e3@mail.gmail.com>
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806040159o648392a1l3dbd84d9c765a847@mail.gmail.com>
	<20080604181528.f4c94743.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830806040215j4f49483bnfa474eb27120a5e3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Jun 2008 02:15:32 -0700
"Paul Menage" <menage@google.com> wrote:

> On Wed, Jun 4, 2008 at 2:15 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> Should we try to support hierarchy and non-hierarchy cgroups in the
> >> same tree? Maybe we should just enforce the restrictions that:
> >>
> >> - the hierarchy mode can't be changed on a cgroup if you have children
> >> or any non-zero usage/limit
> >> - a cgroup inherits its parent's hierarchy mode.
> >>
> > Ah, my patch does it (I think).  explanation is bad.
> >
> > - mem cgroup's mode can be changed against ROOT node which has no children.
> > - a child inherits parent's mode.
> 
> But if it can only be changed for the root cgroup when it has no
> children, than implies that all cgroups must have the same mode. I'm
> suggesting that we allow non-root cgroups to change their mode, as
> long as:
> 
> - they have no children
> 
> - they don't have any limit charged to their parent (which means that
> either they have a zero limit, or they have no parent, or they're not
> in hierarchy mode)
> 
Hmm, I got your point. Your suggestion seems reasonable.
I'll try that logic in the next version.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/5] memcg: change for softlimit.
Date: Fri, 28 Aug 2009 20:16:48 +0530
Message-ID: <20090828144648.GO4889@balbir.in.ibm.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com> <20090828132321.e4a497bb.kamezawa.hiroyu@jp.fujitsu.com> <20090828072007.GH4889@balbir.in.ibm.com> <20090828163523.e51678be.kamezawa.hiroyu@jp.fujitsu.com> <20090828132643.GM4889@balbir.in.ibm.com> <bfd50d44ff730c2720b882a81b7446c6.squirrel@webmail-b.css.fujitsu.com> <712c0209222358d9c7d1e33f93e21c30.squirrel@webmail-b.css.fujitsu.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751781AbZH1Oq5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <712c0209222358d9c7d1e33f93e21c30.squirrel@webmail-b.css.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-Id: linux-mm.kvack.org

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28 23:40:56]:

> KAMEZAWA Hiroyuki wrote:
> > Balbir Singh wrote:
> >> But Bob and Mike might need to set soft limits between themselves. if
> >> soft limit of gold is 1G and bob needs to be close to 750M and mike
> >> 250M, how do we do it without supporting what we have today?
> >>
> > Don't use hierarchy or don't use softlimit.
> > (I never think fine-grain  soft limit can be useful.)
> >
> > Anyway, I have to modify unnecessary hacks for res_counter of softlimit.
> > plz allow modification. that's bad.
> > I postpone RB-tree breakage problem, plz explain it or fix it by yourself.
> >
> I changed my mind....per-zone RB-tree is also broken ;)
> 
> Why I don't like broken system is a function which a user can't
> know/calculate how-it-works is of no use in mission critical systems.
> 
> I'd like to think how-to-fix it with better algorithm. Maybe RB-tree
> is not a choice.
>

Soft limits are not meant for mission critical work :-) Soft limits is
best effort and not a guaranteed resource allocation mechanism. I've
mentioned in previous emails how we recover if we find the data is
stale

 

-- 
	Balbir

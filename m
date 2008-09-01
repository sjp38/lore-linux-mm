Date: Mon, 1 Sep 2008 16:01:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/14]  memcg: free page_cgroup by RCU
Message-Id: <20080901160151.4cd2ca3c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080901065144.CCA975A9C@siro.lan>
References: <20080828194454.3fa6d0d0.kamezawa.hiroyu@jp.fujitsu.com>
	<20080901065144.CCA975A9C@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Mon,  1 Sep 2008 15:51:44 +0900 (JST)
yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:

> hi,
> 
> > > > @@ -649,13 +673,17 @@ static DEFINE_MUTEX(memcg_force_drain_mu
> > > > 
> > > >  static void mem_cgroup_local_force_drain(struct work_struct *work)
> > > >  {
> > > > -	__free_obsolete_page_cgroup();
> > > > +	int ret;
> > > > +	do {
> > > > +		ret = __free_obsolete_page_cgroup();
> > > 
> > > We keep repeating till we get 0?
> > > 
> > yes. this returns 0 or -ENOMEM. 
> 
> it's problematic to keep busy-looping on ENOMEM, esp. for GFP_ATOMIC.
> 
Ah thank you. I remove this routine in the next version.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

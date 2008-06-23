Date: Mon, 23 Jun 2008 20:44:48 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [bad page] memcg: another bad page at page migration
 (2.6.26-rc5-mm3 + patch collection)
Message-Id: <20080623204448.2c4326ab.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080623202111.f2c54e21.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080623145341.0a365c67.nishimura@mxp.nes.nec.co.jp>
	<20080623150817.628aef9f.kamezawa.hiroyu@jp.fujitsu.com>
	<20080623202111.f2c54e21.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jun 2008 20:21:11 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 23 Jun 2008 15:08:17 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Mon, 23 Jun 2008 14:53:41 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > Hi.
> > > 
> > > It seems the current -mm has been gradually stabilized,
> > > but I encounter another bad page problem in my test(*1)
> > > on 2.6.26-rc5-mm3 + patch collection(*2).
> > > 
> > > Compared to previous probrems fixed by the patch collection,
> > > the frequency is law.
> > > 
> > > - 1 time in 1 hour running(1'st one was seen after 30 minutes)
> > > - 3 times in 16 hours running(1'st one was seen after 4 hours)
> > > - 10 times in 70 hours running(1'st one was seen after 8 hours)
> > > 
> > > All bad pages show similar message like below:
> > > 
> > Thank you. I'll dig this.
> > 
> > 
> Here is one possibilty. But if your test doesn't migrate any shmem, 
> I'll have to dig more ;)
> Anyway, I'll schedule this patch.
> 
Thank you for your investigation and a patch!

I don't use shmem explicitly, but I'll test this patch anyway
and report the result.

Considering the frequency of the problem, it will take long time 
to tell whether this patch fixes the problem, so please wait :)


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

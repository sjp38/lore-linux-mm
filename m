Subject: Re: [PATCH 10/10] mm: per device dirty threshold
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0704230847400.10624@schroedinger.engr.sgi.com>
References: <20070420155154.898600123@chello.nl>
	 <20070420155503.608300342@chello.nl>
	 <20070421025532.916b1e2e.akpm@linux-foundation.org>
	 <1177156902.2934.96.camel@lappy> <1177157708.2934.100.camel@lappy>
	 <Pine.LNX.4.64.0704230847400.10624@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 23 Apr 2007 17:58:20 +0200
Message-Id: <1177343900.26937.6.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 2007-04-23 at 08:48 -0700, Christoph Lameter wrote:
> On Sat, 21 Apr 2007, Peter Zijlstra wrote:
> 
> > > > This is enormously wrong for CONFIG_NR_CPUS=1024 on a 2-way.
> > 
> > Right, I knew about that but, uhm.
> > 
> > I wanted to make that num_online_cpus(), and install a hotplug notifier
> > to fold the percpu delta back into the total on cpu offline.
> 
> Use nr_cpu_ids instead. Contains the maximum possible cpus on this 
> hardware and allows to handle the hotplug case easily.

Ooh, thats handy... /me ditches the hotplug code again.
That is, unless its very common to have half empty boxens.. ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

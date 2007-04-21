Subject: Re: [PATCH 10/10] mm: per device dirty threshold
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1177156902.2934.96.camel@lappy>
References: <20070420155154.898600123@chello.nl>
	 <20070420155503.608300342@chello.nl>
	 <20070421025532.916b1e2e.akpm@linux-foundation.org>
	 <1177156902.2934.96.camel@lappy>
Content-Type: text/plain
Date: Sat, 21 Apr 2007 14:15:08 +0200
Message-Id: <1177157708.2934.100.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

> > > +/*
> > > + * maximal error of a stat counter.
> > > + */
> > > +static inline unsigned long bdi_stat_delta(void)
> > > +{
> > > +#ifdef CONFIG_SMP
> > > +	return NR_CPUS * FBC_BATCH;
> > 
> > This is enormously wrong for CONFIG_NR_CPUS=1024 on a 2-way.

Right, I knew about that but, uhm.

I wanted to make that num_online_cpus(), and install a hotplug notifier
to fold the percpu delta back into the total on cpu offline.

But I have to look into doing that hotplug notifier stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

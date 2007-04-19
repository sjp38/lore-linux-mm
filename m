Subject: Re: [PATCH 09/12] mm: count unstable pages per BDI
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1177008406.2934.19.camel@lappy>
References: <20070417071046.318415445@chello.nl>
	 <20070417071703.710381113@chello.nl>
	 <E1Heafy-0006ia-00@dorka.pomaz.szeredi.hu> <1177006362.2934.13.camel@lappy>
	 <1177008406.2934.19.camel@lappy>
Content-Type: text/plain
Date: Thu, 19 Apr 2007 21:00:36 +0200
Message-Id: <1177009236.7066.19.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-04-19 at 20:46 +0200, Peter Zijlstra wrote:
> On Thu, 2007-04-19 at 20:12 +0200, Peter Zijlstra wrote:
> > On Thu, 2007-04-19 at 19:44 +0200, Miklos Szeredi wrote:
> > > > Count per BDI unstable pages.
> > > > 
> > > 
> > > I'm wondering, is it really worth having this category separate from
> > > per BDI brity pages?
> > > 
> > > With the exception of the export to sysfs, always the sum of unstable
> > > + dirty is used.
> > 
> > I guess you are right, but it offends my sense of aesthetics to break
> > symmetry with the zone statistics. However, it has the added advantage
> > of only needing 2 deltas as well.
> 
> I guess, this should do.

OK, the compiler told me I messed up :-/. I'll respin the whole series
and repost tomorrow or something...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

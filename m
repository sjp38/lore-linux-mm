Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B9F3B62001F
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 15:15:52 -0400 (EDT)
Date: Wed, 17 Mar 2010 15:15:14 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v7)
Message-ID: <20100317191514.GC9198@redhat.com>
References: <1268609202-15581-1-git-send-email-arighi@develer.com> <20100315171209.GI21127@redhat.com> <20100315171921.GJ21127@redhat.com> <20100317115427.GR18054@balbir.in.ibm.com> <20100317133407.GA9198@redhat.com> <20100317185327.GV18054@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100317185327.GV18054@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 18, 2010 at 12:23:27AM +0530, Balbir Singh wrote:
> * Vivek Goyal <vgoyal@redhat.com> [2010-03-17 09:34:07]:
> 
> > > > 
> > > > root cgroup
> > > > ==========
> > > > #time dd if=/dev/zero of=/root/zerofile bs=4K count=1M
> > > > 4294967296 bytes (4.3 GB) copied, 56.098 s, 76.6 MB/s
> > > > 
> > > > real	0m56.614s
> > > > 
> > > > test1 cgroup with memory limit 100M
> > > > ===================================
> > > > # time dd if=/dev/zero of=/root/zerofile1 bs=4K count=1M
> > > > 4294967296 bytes (4.3 GB) copied, 19.8097 s, 217 MB/s
> > > > 
> > > > real	0m19.992s
> > > > 
> > > 
> > > This is strange, did you flish the cache between the two runs?
> > > NOTE: Since the files are same, we reuse page cache from the
> > > other cgroup.
> > 
> > Files are different. Note suffix "1".
> >
> 
> Thanks, I'll get the perf output and see what I get. 

One more thing I noticed and that is, it happens only if we limit the
memory of cgroup to 100M. If same cgroup test1 is unlimited memory 
thing, then it did not happen.

I also did not notice this happening on other system where I have 4G of
memory. So it also seems to be related with only bigger configurations.

Thanks
Vivek

> 
> -- 
> 	Three Cheers,
> 	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

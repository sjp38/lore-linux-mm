Received: from edge01.upc.biz ([192.168.13.236]) by viefep12-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080725111854.LCKK29370.viefep12-int.chello.at@edge01.upc.biz>
          for <linux-mm@kvack.org>; Fri, 25 Jul 2008 13:18:54 +0200
Subject: Re: [PATCH 30/30] nfs: fix various memory recursions possible with
	swap over NFS.
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080725201324.86BE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080725194517.86BB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1216983472.7257.365.camel@twins>
	 <20080725201324.86BE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 25 Jul 2008 13:19:01 +0200
Message-Id: <1216984741.7257.366.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-07-25 at 20:15 +0900, KOSAKI Motohiro wrote:
> > On Fri, 2008-07-25 at 19:46 +0900, KOSAKI Motohiro wrote:
> > > > GFP_NOFS is not enough, since swap traffic is IO, hence fall back to GFP_NOIO.
> > > 
> > > this comment imply turn on GFP_NOIO, but the code is s/NOFS/NOIO/. why?
> > 
> > Does the misunderstanding stem from the use of 'enough'?
> > 
> > GFP_NOFS is _more_ permissive than GFP_NOIO in that it will initiate IO,
> > just not of any filesystem data.
> > 
> 
> 
> > The problem is that previuosly NOFS was correct because that avoids
> > recursion into the NFS code, it now is not, because also IO (swap) can
> > lead to this recursion.
> 
> 
> Thanks nicer explain.
> So, I hope add above 3 line to patch description.

Done, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

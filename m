Date: Mon, 23 May 2005 21:54:11 +0900 (JST)
Message-Id: <20050523.215411.124651572.taka@valinux.co.jp>
Subject: Re: [PATCH 0/6] CKRM: Memory controller for CKRM
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20050521000700.GA30327@chandralinux.beaverton.ibm.com>
References: <20050519163338.GC27270@chandralinux.beaverton.ibm.com>
	<20050520.142927.108372625.taka@valinux.co.jp>
	<20050521000700.GA30327@chandralinux.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chandra,

> > > > > 
> > > > > I am looking for improvement suggestions
> > > > >         - to not have a field in the page data structure for the mem
> > > > >           controller
> > > > 
> > > > What do you think if you make each class owns inodes instead of pages
> > > > in the page-cache?
> 
> I think i missed to answer this question in the earlier reply.
> 
> do you mean a controller for managing inodes ?

Yes, I think it might be another solution though I haven't examined
about it yet.


Thanks,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

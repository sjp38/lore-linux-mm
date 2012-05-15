Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 54DF56B0083
	for <linux-mm@kvack.org>; Tue, 15 May 2012 09:16:37 -0400 (EDT)
Date: Tue, 15 May 2012 21:15:33 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/2 v2] Flexible proportions for BDIs
Message-ID: <20120515131533.GA4753@localhost>
References: <1336084760-19534-1-git-send-email-jack@suse.cz>
 <20120507144344.GA13983@localhost>
 <20120509113720.GC5092@quack.suse.cz>
 <20120510073123.GA7523@localhost>
 <20120511145114.GA18227@localhost>
 <20120513032952.GA8099@localhost>
 <20120514212803.GT5353@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120514212803.GT5353@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, peterz@infradead.org

Hi Jan,

> > The observations for this box are
> > 
> > - the 3s and 8s periods result in roughly the same adaption speed
> > 
> > - the patch makes a really *big* difference in systems with big
> >   memory:bandwidth ratio. It's sweet! In comparison, the vanilla
> >   kernel adapts to new write bandwidth so much slower.
>   Yes, in this configuration the benefit of the new algorithm can be clearly
> seen. Together with the results of previous test I'd say 3s period is the
> best candidate.
 
Agreed. I'm fine with the fixed 3s period. 

>   Just I was thinking whether the period shouldn't be somehow set
> automatically because I'm not convinced 3s will be right for everybody...
> Maybe something based on how big fluctuations in completion rate we
> observe. But it would be tricky given the load itself changes as well. So
> for now we'll have to live with a hardwired period I guess.

Yeah, simple fixed periods should be good enough.

>   Thanks for the tests Fengguang! So is anybody against merging this?

No problem for me, when Peter's concern is addressed.

Thanks!

Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

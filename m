Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA38D6B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 19:33:16 -0500 (EST)
Date: Wed, 19 Jan 2011 09:27:33 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH v4] mm: add replace_page_cache_page() function
Message-Id: <20110119092733.4927f935.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110118152844.88cfdc2c.akpm@linux-foundation.org>
References: <E1Pf9Zj-0002td-Ct@pomaz-ex.szeredi.hu>
	<20110118152844.88cfdc2c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, minchan.kim@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011 15:28:44 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 18 Jan 2011 12:18:11 +0100
> Miklos Szeredi <miklos@szeredi.hu> wrote:
> 
> > +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
> > +{
> > +	int error;
> > +	struct mem_cgroup *memcg = NULL;
> 
> I'm suspecting that the unneeded initialisation was added to suppress a
> warning?
> 
No.
It's necessary for mem_cgroup_{prepare|end}_migration().
mem_cgroup_prepare_migration() will return without doing anything in
"if (mem_cgroup_disabled()" case(iow, "memcg" is not overwritten),
but mem_cgroup_end_migration() depends on the value of "memcg" to decide
whether prepare_migration has succeeded or not.
This may not be a good implementation, but IMHO I'd like to to initialize
valuable before using it in general.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

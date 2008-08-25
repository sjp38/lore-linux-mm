Subject: Re: [PATCH 3/7] Mlock: resubmit locked_vm adjustment as separate
	patch
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080822161105.5d47b82b.akpm@linux-foundation.org>
References: <20080822211028.29898.82599.sendpatchset@murky.usa.hp.com>
	 <20080822211047.29898.16176.sendpatchset@murky.usa.hp.com>
	 <20080822161105.5d47b82b.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 25 Aug 2008 09:01:01 -0400
Message-Id: <1219669261.6177.2.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: riel@redhat.com, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, Eric.Whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 2008-08-22 at 16:11 -0700, Andrew Morton wrote:
> On Fri, 22 Aug 2008 17:10:47 -0400
> Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> 
> > @@ -240,13 +240,27 @@ static int __mlock_vma_pages_range(struc
> >  #endif /* CONFIG_UNEVICTABLE_LRU */
> >  
> >  /*
> > - * mlock all pages in this vma range.  For mmap()/mremap()/...
> > +/**
> 
> mm/mlock.c:243:1: warning: "/*" within comment
> 
> what's happening over there?

Indeed.  Lost the warning in the make log.  checkpatch let it slide :(

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

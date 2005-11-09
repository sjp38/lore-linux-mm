Date: Wed, 9 Nov 2005 09:07:36 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 6/8] Direct Migration V2: Avoid writeback / page_migrate()
 method
In-Reply-To: <17265.55057.438316.467289@gargle.gargle.HOWL>
Message-ID: <Pine.LNX.4.62.0511090907260.3607@schroedinger.engr.sgi.com>
References: <20051108210246.31330.61756.sendpatchset@schroedinger.engr.sgi.com>
 <20051108210417.31330.72381.sendpatchset@schroedinger.engr.sgi.com>
 <17265.55057.438316.467289@gargle.gargle.HOWL>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Mike Kravetz <kravetz@us.ibm.com>, linux-kernel@vger.kernel.org, Dave Hansen <haveblue@us.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, torvalds@osdl.org, Hirokazu Takahashi <taka@valinux.co.jp>, Magnus Damm <magnus.damm@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Jackson <pj@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Nov 2005, Nikita Danilov wrote:

>  > +#ifdef CONFIG_MIGRATION
>  > +extern int buffer_migrate_page(struct page *, struct page *);
>  > +#else
>  > +#define buffer_migrate_page(a,b) NULL
>  > +#endif
> 
> Depending on the CONFIG_MIGRATION, the type of buffer_migrate_page(a,b)
> expansion is either int or void *, which doesn't look right.

But its right. You need to think about buffer_migrate_page as a pointer to 
a function.

> Moreover below you have initializations
> 
>         .migrate_page		= buffer_migrate_page,
> 
> that wouldn't compile when CONFIG_MIGRATION is not defined (as macro
> requires two arguments).

NULL is a void * pointer which should work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

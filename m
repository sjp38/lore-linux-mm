Date: Wed, 3 Nov 2004 13:21:29 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: migration cache, updated
Message-ID: <20041103152129.GA4716@logos.cnet>
References: <20041026092535.GE24462@logos.cnet> <20041026.230110.21315175.taka@valinux.co.jp> <20041026122419.GD27014@logos.cnet> <20041027.224837.118287069.taka@valinux.co.jp> <20041028151928.GA7562@logos.cnet> <20041028160520.GB7562@logos.cnet> <41813FCD.3070503@us.ibm.com> <20041028162652.GC7562@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041028162652.GC7562@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, iwamoto@valinux.co.jp, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, Oct 28, 2004 at 02:26:52PM -0200, Marcelo Tosatti wrote:
> On Thu, Oct 28, 2004 at 11:51:57AM -0700, Dave Hansen wrote:
> > Marcelo Tosatti wrote:
> > >+static inline int PageMigration(struct page *page)
> > >+{
> > >+        swp_entry_t entry;
> > >+
> > >+        if (!PageSwapCache(page))
> > >+                return 0;
> > >+
> > >+        entry.val = page->private;
> > >+
> > >+        if (swp_type(entry) != MIGRATION_TYPE)
> > >+                return 0;
> > >+
> > >+        return 1;
> > >+}
> > 
> > Don't we usually try to keep the Page*() operations to be strict 
> > page->flags checks?  Should this be page_migration() or something 
> > similar instead?
> 
> Yeah I think page_migration() will be more conformant to the current
> macros.
> 
> Will do it, and upgrade to the latest -mhp. What is it again? 
 
Can't boot 2.6.9-mm1-mhp on my dual P4 - reverting -mhp 
makes it happy again (with same .config file). Freezes
after "OK, now booting the kernel".

Will stick to -rc4-mm1 for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

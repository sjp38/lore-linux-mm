Date: Sat, 16 Feb 2008 11:28:08 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 5/6] mmu_notifier: Support for drivers with revers maps
 (f.e. for XPmem)
In-Reply-To: <20080215193746.5d823092.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0802161126560.25573@schroedinger.engr.sgi.com>
References: <20080215064859.384203497@sgi.com> <20080215064933.376635032@sgi.com>
 <20080215193746.5d823092.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2008, Andrew Morton wrote:

> > +#define mmu_rmap_notifier(function, args...)				\
> > +	do {								\
> > +		struct mmu_rmap_notifier *__mrn;			\
> > +		struct hlist_node *__n;					\
> > +									\
> > +		rcu_read_lock();					\
> > +		hlist_for_each_entry_rcu(__mrn, __n,			\
> > +				&mmu_rmap_notifier_list, hlist)		\
> > +			if (__mrn->ops->function)			\
> > +				__mrn->ops->function(__mrn, args);	\
> > +		rcu_read_unlock();					\
> > +	} while (0);
> > +
> 
> buggy macro: use locals.

Ok. Same as the non rmap version.

> > +EXPORT_SYMBOL(mmu_rmap_export_page);
> 
> The other patch used EXPORT_SYMBOL_GPL.

Ok will make that consistent.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

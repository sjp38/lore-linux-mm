Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 132656B002D
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 21:19:00 -0500 (EST)
Date: Thu, 10 Nov 2011 03:18:53 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 1/5]thp: improve the error code path
Message-ID: <20111110021853.GQ5075@redhat.com>
References: <1319511521.22361.135.camel@sli10-conroe>
 <20111025114406.GC10182@redhat.com>
 <1319593680.22361.145.camel@sli10-conroe>
 <1320643049.22361.204.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1320643049.22361.204.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

Hi Shaohua,

On Mon, Nov 07, 2011 at 01:17:29PM +0800, Shaohua Li wrote:
> On Wed, 2011-10-26 at 09:48 +0800, Shaohua Li wrote:
> > On Tue, 2011-10-25 at 19:44 +0800, Andrea Arcangeli wrote:
> > > Hello,
> > > 
> > > On Tue, Oct 25, 2011 at 10:58:41AM +0800, Shaohua Li wrote:
> > > > +#ifdef CONFIG_SYSFS
> > > > +	sysfs_remove_group(hugepage_kobj, &khugepaged_attr_group);
> > > > +remove_hp_group:
> > > > +	sysfs_remove_group(hugepage_kobj, &hugepage_attr_group);
> > > > +delete_obj:
> > > > +	kobject_put(hugepage_kobj);
> > > >  out:
> > > > +#endif
> > > 
> > > Adding an ifdef is making the code worse, the whole point of having
> > > these functions become noops at build time is to avoid having to add
> > > ifdefs in the callers.
> > yes, but hugepage_attr_group is defined in CONFIG_SYSFS. And the
> > functions are inline functions. They really should be a '#define xxx'.

hugepage_attr_group is defined even if CONFIG_SYSFS is not set and I
just made a build with CONFIG_SYSFS=n and it builds just fine without
any change.

$ grep CONFIG_SYSFS .config
# CONFIG_SYSFS is not set

So we can drop 1/5 above.

> ping, any comments for the 5 patches?

Apologies for the delay in the answer! I had a few other open items
and the plenty of emails on 5/5 required a bit more time to think
about :). Expect a reply on the other 4 soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

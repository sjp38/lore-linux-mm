Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 800856B002D
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 21:40:20 -0400 (EDT)
Subject: Re: [patch 1/5]thp: improve the error code path
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20111025114406.GC10182@redhat.com>
References: <1319511521.22361.135.camel@sli10-conroe>
	 <20111025114406.GC10182@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 26 Oct 2011 09:48:00 +0800
Message-ID: <1319593680.22361.145.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Tue, 2011-10-25 at 19:44 +0800, Andrea Arcangeli wrote:
> Hello,
> 
> On Tue, Oct 25, 2011 at 10:58:41AM +0800, Shaohua Li wrote:
> > +#ifdef CONFIG_SYSFS
> > +	sysfs_remove_group(hugepage_kobj, &khugepaged_attr_group);
> > +remove_hp_group:
> > +	sysfs_remove_group(hugepage_kobj, &hugepage_attr_group);
> > +delete_obj:
> > +	kobject_put(hugepage_kobj);
> >  out:
> > +#endif
> 
> Adding an ifdef is making the code worse, the whole point of having
> these functions become noops at build time is to avoid having to add
> ifdefs in the callers.
yes, but hugepage_attr_group is defined in CONFIG_SYSFS. And the
functions are inline functions. They really should be a '#define xxx'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

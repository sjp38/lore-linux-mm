Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 19C8A6B0389
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 16:48:14 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id i66so46830020yba.4
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:48:14 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id a206si905758ywc.27.2017.02.24.13.48.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 13:48:13 -0800 (PST)
Date: Fri, 24 Feb 2017 13:47:25 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V4 6/6] proc: show MADV_FREE pages info in smaps
Message-ID: <20170224214724.GA35601@shli-mbp.local>
References: <cover.1487788131.git.shli@fb.com>
 <7f22d33b2f388ce33448faa75be75f9a52d57052.1487788131.git.shli@fb.com>
 <e118502c-6be7-2ca5-bd3c-1f390a3961df@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <e118502c-6be7-2ca5-bd3c-1f390a3961df@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 24, 2017 at 09:08:30AM -0800, Dave Hansen wrote:
> On 02/22/2017 10:50 AM, Shaohua Li wrote:
> > @@ -770,6 +774,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
> >  		   "Private_Dirty:  %8lu kB\n"
> >  		   "Referenced:     %8lu kB\n"
> >  		   "Anonymous:      %8lu kB\n"
> > +		   "LazyFree:       %8lu kB\n"
> >  		   "AnonHugePages:  %8lu kB\n"
> >  		   "ShmemPmdMapped: %8lu kB\n"
> >  		   "Shared_Hugetlb: %8lu kB\n"
> 
> I've been as guily of this in the past as anyone, but are we just going
> to keep adding fields to smaps forever?  For the vast, vast, majority of
> folks, this will simply waste the 21 bytes * nr_vmas that it costs us to
> print "LazyFree:       0 kB\n" over and over.
> 
> Should we maybe start a habit of not printing an entry when it's "0 kB"?

Interesting idea! I'd like this is a separate patch if we go this way, because
this is likely to be controversial. That said, sounds there is no reason we
shouldn't do this.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

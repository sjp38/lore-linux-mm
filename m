Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4939A6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 02:41:01 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p5A6eufD028514
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 23:40:57 -0700
Received: from pzk35 (pzk35.prod.google.com [10.243.19.163])
	by kpbe15.cbf.corp.google.com with ESMTP id p5A6eoJt022721
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 23:40:54 -0700
Received: by pzk35 with SMTP id 35so1597600pzk.39
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 23:40:50 -0700 (PDT)
Date: Thu, 9 Jun 2011 23:40:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 5/7] tmpfs: simplify prealloc_page
In-Reply-To: <1307671323.15392.76.camel@sli10-conroe>
Message-ID: <alpine.LSU.2.00.1106092334440.12180@sister.anvils>
References: <alpine.LSU.2.00.1106091529060.2200@sister.anvils> <alpine.LSU.2.00.1106091535510.2200@sister.anvils> <1307671323.15392.76.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 10 Jun 2011, Shaohua Li wrote:
> On Fri, 2011-06-10 at 06:39 +0800, Hugh Dickins wrote:
> > @@ -1492,11 +1460,19 @@ repeat:
> >  		SetPageUptodate(filepage);
> >  		if (sgp == SGP_DIRTY)
> >  			set_page_dirty(filepage);
> > +	} else {
> Looks info->lock unlock is missed here.
> Otherwise looks good to me.

Many thanks for catching that!  Replacements for this patch,
and the next which then rejects, follow as replies.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1F42B8D0039
	for <linux-mm@kvack.org>; Sun, 20 Feb 2011 16:54:20 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p1KLsFCF017036
	for <linux-mm@kvack.org>; Sun, 20 Feb 2011 13:54:15 -0800
Received: from pvg3 (pvg3.prod.google.com [10.241.210.131])
	by wpaz5.hot.corp.google.com with ESMTP id p1KLsDa7022069
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 20 Feb 2011 13:54:14 -0800
Received: by pvg3 with SMTP id 3so487514pvg.4
        for <linux-mm@kvack.org>; Sun, 20 Feb 2011 13:54:13 -0800 (PST)
Date: Sun, 20 Feb 2011 13:54:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/5] fix up /proc/$pid/smaps to not split huge pages
In-Reply-To: <20110209212404.GR3347@random.random>
Message-ID: <alpine.DEB.2.00.1102201352570.26991@chino.kir.corp.google.com>
References: <20110209195406.B9F23C9F@kernel> <20110209212404.GR3347@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>

On Wed, 9 Feb 2011, Andrea Arcangeli wrote:

> On Wed, Feb 09, 2011 at 11:54:06AM -0800, Dave Hansen wrote:
> > Andrea, after playing with this for a week or two, I'm quite a bit
> > more confident that it's not causing much harm.  Seems a fairly
> > low-risk feature.  Could we stick these somewhere so they'll at
> > least hit linux-next for the 2.6.40 cycle perhaps?
> 
> I think they're good to go in mmotm already and to be merged ASAP.
> 
> The only minor issue I have is the increment, to become per-cpu. Are
> we going to change its location then or it's still read through sysfs?
> 

Dave, I notice these patches haven't been merged into -mm yet.  Are we 
waiting on another iteration or is this set ready to go?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

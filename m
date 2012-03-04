Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id A92EB6B00E8
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 12:38:54 -0500 (EST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 4 Mar 2012 17:34:55 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q24Hc4Jr934086
	for <linux-mm@kvack.org>; Mon, 5 Mar 2012 04:38:12 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q24Hc4cU026709
	for <linux-mm@kvack.org>; Mon, 5 Mar 2012 04:38:04 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V2 1/9] mm:  move hugetlbfs region tracking function to common code
In-Reply-To: <20120301143345.7e928efe.akpm@linux-foundation.org>
References: <1330593380-1361-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1330593380-1361-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120301143345.7e928efe.akpm@linux-foundation.org>
Date: Sun, 04 Mar 2012 23:07:50 +0530
Message-ID: <87linge07l.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrea Righi <andrea@betterlinux.com>, John Stultz <john.stultz@linaro.org>

On Thu, 1 Mar 2012 14:33:45 -0800, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu,  1 Mar 2012 14:46:12 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > This patch moves the hugetlbfs region tracking function to
> > common code. We will be using this in later patches in the
> > series.
> > 
> > ...
> >
> > +struct file_region {
> > +	struct list_head link;
> > +	long from;
> > +	long to;
> > +};
> 
> Both Andrea Righi and John Stultz are working on (more sophisticated)
> versions of file region tracking code.  And we already have a (poor)
> implementation in fs/locks.c.
> 
> That's four versions of the same thing floating around the place.  This
> is nutty.


We should be able to remove region.c once other alternatives are in
upstream. I will also look at the alternatives and see if it would need
any change to make it usable for this work.

Thanks,
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

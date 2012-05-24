Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id A87616B0083
	for <linux-mm@kvack.org>; Thu, 24 May 2012 01:15:34 -0400 (EDT)
Date: Wed, 23 May 2012 22:16:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg/hugetlb: Add failcnt support for hugetlb
 extension
Message-Id: <20120523221655.a067710b.akpm@linux-foundation.org>
In-Reply-To: <87likiyyxr.fsf@skywalker.in.ibm.com>
References: <1337686991-26418-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20120523161750.f0e22c5b.akpm@linux-foundation.org>
	<87likiyyxr.fsf@skywalker.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz

On Thu, 24 May 2012 10:10:00 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Tue, 22 May 2012 17:13:11 +0530
> > "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> >
> >> Expose the failcnt details to userspace similar to memory and memsw.
> >
> > Why?
> >
> 
> to help us find whether there was an allocation failure due to HugeTLB
> limit. 

How are we to know that is that useful enough to justify expanding the
kernel API?

Yes, regular memcg has it, but that isn't a reason.  Do we know that
people are using that?  That it is useful?

Also, "cnt" is not a word.  It should be "failcount" or, even better,
"failure_count".  Or, smarter, "failures".  But we screwed that up a
long time ago and can't fix it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

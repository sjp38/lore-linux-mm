Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 728E66B004A
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 17:44:45 -0500 (EST)
Date: Thu, 1 Mar 2012 14:44:43 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -V2] hugetlbfs: Drop taking inode i_mutex lock from
 hugetlbfs_read
Message-Id: <20120301144443.7b4fe22a.akpm@linux-foundation.org>
In-Reply-To: <CA+5PVA4AcTWHsUskGqxdka2G7JMsDpjtdhw23vSHafgAGg4opQ@mail.gmail.com>
References: <1330593530-2022-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20120301141007.274ad458.akpm@linux-foundation.org>
	<CA+5PVA4AcTWHsUskGqxdka2G7JMsDpjtdhw23vSHafgAGg4opQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Boyer <jwboyer@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, viro@zeniv.linux.org.uk, hughd@google.com, linux-kernel@vger.kernel.org


On Thu, 1 Mar 2012 17:40:41 -0500
Josh Boyer <jwboyer@gmail.com> wrote:

> We've gotten a few lockdep reports about it in Fedora on various kernels.
> A CC to stable might be nice.
> 

On Thu, 1 Mar 2012 17:40:14 -0500
Dave Jones <davej@redhat.com> wrote:

> My testing hits this every day. It's not a real problem, but it's annoying
> to see the lockdep spew constantly.  We've had a couple Fedora users
> report it too in regular day-to-day use as opposed to the hostile
> workloads I use to provoke it.
> 
> FWIW, I'll probably throw it in the Fedora kernels, so if it ends up
> in stable, it'll be one less patch to carry.

OK, thanks guys.  Cc:stable is added.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

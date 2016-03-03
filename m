Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1D4828DF
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 17:08:12 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id n186so9762095wmn.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 14:08:12 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id k11si534863wjw.224.2016.03.03.14.08.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 14:08:11 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id l68so9826654wml.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 14:08:11 -0800 (PST)
Date: Fri, 4 Mar 2016 00:08:03 +0200
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [RFC v5 0/3] mm: make swapin readahead to gain more thp
 performance
Message-ID: <20160303220803.GA9898@debian>
Reply-To: hughd@google.com
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
 <20150914144106.ee205c3ae3f4ec0e5202c9fe@linux-foundation.org>
 <alpine.LSU.2.11.1602242301040.6947@eggly.anvils>
 <1456439750.15821.97.camel@redhat.com>
 <20160225233017.GA14587@debian>
 <alpine.LSU.2.11.1602252151030.9793@eggly.anvils>
 <1456498316.25322.35.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1456498316.25322.35.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, riel@redhat.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Fri, Feb 26, 2016 at 09:51:56AM -0500, Rik van Riel wrote:
> On Thu, 2016-02-25 at 22:17 -0800, Hugh Dickins wrote:
> > On Fri, 26 Feb 2016, Ebru Akagunduz wrote:
> > > in Thu, Feb 25, 2016 at 05:35:50PM -0500, Rik van Riel wrote:
> > 
> > > > Am I forgetting anything obvious?
> > > > 
> > > > Is this too aggressive?
> > > > 
> > > > Not aggressive enough?
> > > > 
> > > > Could PGPGOUT + PGSWPOUT be a useful
> > > > in-between between just PGSWPOUT or
> > > > PGSTEAL_*?
> > 
> > I've no idea offhand, would have to study what each of those
> > actually means: I'm really not familiar with them myself.
> 
> There are a few levels of page reclaim activity:
> 
> PGSTEAL_* - any page was reclaimed, this could just
>             be file pages for streaming file IO,etc
> 
> PGPGOUT   - the VM wrote pages back to disk to reclaim
>             them, this could include file pages
> 
> PGSWPOUT  - the VM wrote something to swap to reclaim
>             memory
> 
> I am not sure which level of aggressiveness khugepaged
> should check against, but my gut instinct would probably
> be the second or third.

I tested with PGPGOUT, it does not help as I expect.
As Rik's suggestion, PSWPOUT and ALLOCSTALL can be good.

I started to prepare the patch last week. Just wanted to
make you sure.

Kind regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id EEE656B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 01:12:23 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so82787990pdr.2
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 22:12:23 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id c9si58787120pas.144.2015.07.28.22.12.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 22:12:22 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NS8012DKH4K29E0@mailout1.samsung.com> for linux-mm@kvack.org;
 Wed, 29 Jul 2015 14:12:20 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1437114578-2502-1-git-send-email-pintu.k@samsung.com>
 <1437366544-32673-1-git-send-email-pintu.k@samsung.com>
 <20150720082810.GG2561@suse.de> <02c601d0c306$f86d30f0$e94792d0$@samsung.com>
 <20150720175538.GJ2561@suse.de> <05af01d0c47f$3337ccd0$99a76670$@samsung.com>
 <20150722140530.GK2561@suse.de>
In-reply-to: <20150722140530.GK2561@suse.de>
Subject: RE: [PATCH v3 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory
 feature
Date: Wed, 29 Jul 2015 10:41:10 +0530
Message-id: <030e01d0c9bd$20e1df60$62a59e20$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@suse.de>
Cc: akpm@linux-foundation.org, corbet@lwn.net, vbabka@suse.cz, gorcunov@openvz.org, mhocko@suse.cz, emunson@akamai.com, kirill.shutemov@linux.intel.com, standby24x7@gmail.com, hannes@cmpxchg.org, vdavydov@parallels.com, hughd@google.com, minchan@kernel.org, tj@kernel.org, rientjes@google.com, xypron.glpk@gmx.de, dzickus@redhat.com, prarit@redhat.com, ebiederm@xmission.com, rostedt@goodmis.org, uobergfe@redhat.com, paulmck@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, ddstreet@ieee.org, sasha.levin@oracle.com, koct9i@gmail.com, cj@linux.com, opensource.ganesh@gmail.com, vinmenon@codeaurora.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, qiuxishi@huawei.com, Valdis.Kletnieks@vt.edu, cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com, pintu.ping@gmail.com, pintu.k@outlook.com

Sorry, for late reply.

> -----Original Message-----
> From: Mel Gorman [mailto:mgorman@suse.de]
> Sent: Wednesday, July 22, 2015 7:36 PM
> To: PINTU KUMAR
> Cc: akpm@linux-foundation.org; corbet@lwn.net; vbabka@suse.cz;
> gorcunov@openvz.org; mhocko@suse.cz; emunson@akamai.com;
> kirill.shutemov@linux.intel.com; standby24x7@gmail.com;
> hannes@cmpxchg.org; vdavydov@parallels.com; hughd@google.com;
> minchan@kernel.org; tj@kernel.org; rientjes@google.com;
> xypron.glpk@gmx.de; dzickus@redhat.com; prarit@redhat.com;
> ebiederm@xmission.com; rostedt@goodmis.org; uobergfe@redhat.com;
> paulmck@linux.vnet.ibm.com; iamjoonsoo.kim@lge.com; ddstreet@ieee.org;
> sasha.levin@oracle.com; koct9i@gmail.com; cj@linux.com;
> opensource.ganesh@gmail.com; vinmenon@codeaurora.org; linux-
> doc@vger.kernel.org; linux-kernel@vger.kernel.org; linux-mm@kvack.org; linux-
> pm@vger.kernel.org; qiuxishi@huawei.com; Valdis.Kletnieks@vt.edu;
> cpgs@samsung.com; pintu_agarwal@yahoo.com; vishnu.ps@samsung.com;
> rohit.kr@samsung.com; iqbal.ams@samsung.com; pintu.ping@gmail.com;
> pintu.k@outlook.com
> Subject: Re: [PATCH v3 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory
> feature
> 
> On Wed, Jul 22, 2015 at 06:33:26PM +0530, PINTU KUMAR wrote:
> > Dear Mel, thank you very much for your comments and suggestions.
> > I will drop this one and look on further improving direct_reclaim and
> > compaction.
> > Just few more comments below before I close.
> >
> > Also, during this patch, I feel that the hibernation_mode part in
> > shrink_all_memory can be corrected.
> > So, can I separately submit the below patch?
> > That is instead of hard-coding the hibernation_mode, we can get
> > hibernation status using:
> > system_entering_hibernation()
> >
> > Please let me know your suggestion about this changes.
> >
> > -#ifdef CONFIG_HIBERNATION
> > +#if defined CONFIG_HIBERNATION || CONFIG_SHRINK_MEMORY
> 
I was talking about only the following case.
Instead of hard coding the hibernation_mode in shrink_all_memory, 
We can set it at runtime.

-               .hibernation_mode = 1,

+       if (system_entering_hibernation())
+               sc.hibernation_mode = 1;
+       else
+               sc.hibernation_mode = 0;

The PM owners should confirm if this is ok.
Once confirmed, I will submit the full patch set.

+> This appears to be a patch on top of "Add /proc/sys/vm/shrink_memory feature"
> so I do not see what would be separately submitted that would make sense.
> 
And we don't need to have /proc/sys/vm/shrink_memory patch for this.

However, if required, we can also expose shrink_all_memory() outside the
hibernation using the CONFIG_SHRINK_MEMORY.
Otherwise, we can neglect other changes.

> --
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

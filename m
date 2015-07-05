Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3510B280291
	for <linux-mm@kvack.org>; Sat,  4 Jul 2015 22:17:30 -0400 (EDT)
Received: by qkbp125 with SMTP id p125so96079538qkb.2
        for <linux-mm@kvack.org>; Sat, 04 Jul 2015 19:17:30 -0700 (PDT)
Received: from nm44-vm9.bullet.mail.bf1.yahoo.com (nm44-vm9.bullet.mail.bf1.yahoo.com. [216.109.115.45])
        by mx.google.com with ESMTPS id z102si16078825qkg.53.2015.07.04.19.17.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 04 Jul 2015 19:17:27 -0700 (PDT)
Date: Sun, 5 Jul 2015 02:15:06 +0000 (UTC)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Message-ID: <32721799.2647113.1436062506299.JavaMail.yahoo@mail.yahoo.com>
In-Reply-To: <169308.1436040527@turing-police.cc.vt.edu>
References: <169308.1436040527@turing-police.cc.vt.edu>
Subject: Re: [PATCH 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory
 feature
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>, Pintu Kumar <pintu.k@samsung.com>
Cc: "corbet@lwn.net" <corbet@lwn.net>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "gorcunov@openvz.org" <gorcunov@openvz.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "emunson@akamai.com" <emunson@akamai.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "standby24x7@gmail.com" <standby24x7@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "hughd@google.com" <hughd@google.com>, "minchan@kernel.org" <minchan@kernel.org>, "tj@kernel.org" <tj@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "xypron.glpk@gmx.de" <xypron.glpk@gmx.de>, "dzickus@redhat.com" <dzickus@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "uobergfe@redhat.com" <uobergfe@redhat.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, "cj@linux.com" <cj@linux.com>, "opensource.ganesh@gmail.com" <opensource.ganesh@gmail.com>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "cpgs@samsung.com" <cpgs@samsung.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, "rohit.kr@samsung.com" <rohit.kr@samsung.com>, "iqbal.ams@samsung.com" <iqbal.ams@samsung.com>





----- Original Message -----
> From: "Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>
> To: Pintu Kumar <pintu.k@samsung.com>
> Cc: corbet@lwn.net; akpm@linux-foundation.org; vbabka@suse.cz; gorcunov@openvz.org; mhocko@suse.cz; emunson@akamai.com; kirill.shutemov@linux.intel.com; standby24x7@gmail.com; hannes@cmpxchg.org; vdavydov@parallels.com; hughd@google.com; minchan@kernel.org; tj@kernel.org; rientjes@google.com; xypron.glpk@gmx.de; dzickus@redhat.com; prarit@redhat.com; ebiederm@xmission.com; rostedt@goodmis.org; uobergfe@redhat.com; paulmck@linux.vnet.ibm.com; iamjoonsoo.kim@lge.com; ddstreet@ieee.org; sasha.levin@oracle.com; koct9i@gmail.com; mgorman@suse.de; cj@linux.com; opensource.ganesh@gmail.com; vinmenon@codeaurora.org; linux-doc@vger.kernel.org; linux-kernel@vger.kernel.org; linux-mm@kvack.org; linux-pm@vger.kernel.org; cpgs@samsung.com; pintu_agarwal@yahoo.com; vishnu.ps@samsung.com; rohit.kr@samsung.com; iqbal.ams@samsung.com
> Sent: Sunday, 5 July 2015 1:38 AM
> Subject: Re: [PATCH 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory feature
> 
> On Fri, 03 Jul 2015 18:50:07 +0530, Pintu Kumar said:
> 
>>  This patch provides 2 things:
> 
>>  2. Enable shrink_all_memory API in kernel with new CONFIG_SHRINK_MEMORY.
>>  Currently, shrink_all_memory function is used only during hibernation.
>>  With the new config we can make use of this API for non-hibernation case
>>  also without disturbing the hibernation case.
> 
>>  --- a/mm/vmscan.c
>>  +++ b/mm/vmscan.c
> 
>>  @@ -3571,12 +3571,17 @@ unsigned long shrink_all_memory(unsigned long 
> nr_to_reclaim)
>>       struct reclaim_state reclaim_state;
>>       struct scan_control sc = {
>>           .nr_to_reclaim = nr_to_reclaim,
>>  +#ifdef CONFIG_SHRINK_MEMORY
>>  +        .gfp_mask = (GFP_HIGHUSER_MOVABLE | GFP_RECLAIM_MASK),
>>  +        .hibernation_mode = 0,
>>  +#else
>>           .gfp_mask = GFP_HIGHUSER_MOVABLE,
>>  +        .hibernation_mode = 1,
>>  +#endif
> 
> 
> That looks like a bug just waiting to happen.  What happens if we
> call an actual hibernation mode in a SHRINK_MEMORY=y kernel, and it finds
> an extra gfp mask bit set, and hibernation_mode set to an unexpected value?

> 


Ok, got it. Thanks for pointing this out.
I will handle HIBERNATION & SHRINK_MEMORY case and send again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

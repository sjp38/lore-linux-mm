Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F0BFC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 20:06:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B6942083B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 20:06:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LQYJYubt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B6942083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC0198E0003; Tue, 12 Feb 2019 15:06:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6E758E0001; Tue, 12 Feb 2019 15:06:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B36DF8E0003; Tue, 12 Feb 2019 15:06:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 82D998E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 15:06:46 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id v131so2425085ywb.19
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:06:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Im/UImNUPFcw5HvyHE9LAW67VL1lLAP8yrfQe/pSfmM=;
        b=kizKCEq6QRrOh6te7EVunwn9WHejLTbzfo2cObDbuyPL5/Vx+l1SnEbKkyz33F38zF
         imgMn0HnklEGYQiEB5UXsAU56gnRekQizykAlF3MN9SrMTV+99lu1+elOr3Mx1wwr2iT
         Ye9vqTWN/pQNZAU4ByrHzDoUy+s8d/teFHkfJFcUPRZGeXh67wP0ty2WnTae0bgiZOjI
         E4YR9EeREUJuzFzNZYkeFwb1AkDGtiVexNFGnS6b1m4mXGyIMjreX/poxXThvtApyXre
         0xnvogmwxeMr0U0mN1PnPDDTmWXeJLjsTE529ZQXZVgdNaNrr76kAUgQlf2C3GLx6qjc
         cWLQ==
X-Gm-Message-State: AHQUAubkai50EuBiZlXJC5/6r7wUtK96YigaOGDRkzARdrz6OibeaUyb
	AqanihPxUgFdg1MObUuAwvn5IMbFb8TiFSOX1Cv3+AIhS4sIgcO9c6MRxoeJjFaNCjf8XQMAm3T
	GJbSQi8X1+vQB4YSiKbn9XMybsQR4Y34iB+mzTqv4S311fNsMws1D5dM4c4TNCsbV3A==
X-Received: by 2002:a25:d088:: with SMTP id h130mr4683005ybg.52.1550002006184;
        Tue, 12 Feb 2019 12:06:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbSUE3+4ZVN7dQKV0UjHjQNGxK6ZAGSRoErdBQhzQm3BeiKGkUyfA3gxRLmU398vJVwyGT+
X-Received: by 2002:a25:d088:: with SMTP id h130mr4682942ybg.52.1550002005450;
        Tue, 12 Feb 2019 12:06:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550002005; cv=none;
        d=google.com; s=arc-20160816;
        b=hesUzfMh3E9y3x5V2ei9NIwmjb4OQI9IatvH+f0KhEJGHiG3sUHCwNvuJ0brTtgaW7
         WCet1by6myCyo01YILq9PEs35n/xvEVMRetNrXDE9fI8M0M+u6BmWP9476sAqjZZTr3a
         BiW61dooS96P1KfRpYq2JwJyMQw1iEwA5OwE717N3CTYb87r/I3FZO/7+oWgU/sYdPUu
         kJSfX4T2GTblDtaS5jlMSSIL0tDmDc+24l0MEZ5BhG+X1dCL6kumAUbafKb2fV1efxI2
         aCkFOChnG2zgU/kgnRnT7uffbL2csOxKff/h06YHNCf1+ZD9hHuvGPmMyJ9bgqvKykgU
         FvZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Im/UImNUPFcw5HvyHE9LAW67VL1lLAP8yrfQe/pSfmM=;
        b=otDsXz18dk09G26AwvsYSO202opOM6/nFQAZXYG2I/Od9vFXHAX7Q3mzu5mEHOapT4
         iFPTPuYhMRAmuNAiSUCOH7cuIG72kctg2pwvKk8dBBguZB26b2YmO9rcNaXwLxw0Z96x
         94zGmVvzpXT6DOYFQ0kiivhrx3rChXFP6BOCXQsVOLXyGOHMugJzNGXewVZezFutrwi1
         jMk57dIy/cR1ZsjhIpPCL/79tpCrKaLUx6V2la706u4PWy0F1Vu7y68YWpCQOVLTeSwz
         fjLn5I6veZngzVl34UtRt5owQ4V+/HehbdfyddJTe9tMPqkiQFhK22A/OCgitTjyRjja
         ImAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LQYJYubt;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l66si8612228ywg.208.2019.02.12.12.06.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 12:06:45 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LQYJYubt;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1CK5Q26133580;
	Tue, 12 Feb 2019 20:06:37 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=Im/UImNUPFcw5HvyHE9LAW67VL1lLAP8yrfQe/pSfmM=;
 b=LQYJYubthalOkYReQ0B1lndMdV8EVf3jey7aisr8hFaVvyF10GFBATiYUiSLGKT6EsSG
 2FFF9XAUqE+waYPdA78AM3cCwrNeaz6sEFAmeHyob474fgKYAtProWoNoZhW7aZ573Yw
 z+FTjuSYJg/znxq9S/mKvuXe+ADw7N43cpE6j9dAeH0ThM35+ao4RchEmcLOWQxO6f1t
 qFEFBdF2Cxzv8IYUnYsCRggq+nBPI490wUw+PFGH3Nr3SwQVZ5sIyb8noYa8yrw5W1Ry
 xTfcLSMutqY0TkvqwqXiwXDBDFgenfnSy3zdqagKh1P2HHdCYJ+7VYhRtS6x92zzZ6ea 4g== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qhredx6nk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 20:06:36 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1CK6ag4011120
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 20:06:36 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1CK6WSI022657;
	Tue, 12 Feb 2019 20:06:32 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 12 Feb 2019 12:06:32 -0800
Date: Tue, 12 Feb 2019 15:06:52 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Andrea Parri <andrea.parri@amarulasolutions.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
        "Huang, Ying" <ying.huang@intel.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
        "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
        Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        Tim Chen <tim.c.chen@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
        Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>,
        Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap
 operations
Message-ID: <20190212200652.bnkiqx6t2dg7ecp5@ca-dmjordan1.us.oracle.com>
References: <20190211083846.18888-1-ying.huang@intel.com>
 <20190211190646.j6pdxqirc56inbbe@ca-dmjordan1.us.oracle.com>
 <20190212032121.GA2723@andrea>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212032121.GA2723@andrea>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9165 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=952 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902120140
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 04:21:21AM +0100, Andrea Parri wrote:
> > > +	if (!si)
> > > +		goto bad_nofile;
> > > +
> > > +	preempt_disable();
> > > +	if (!(si->flags & SWP_VALID))
> > > +		goto unlock_out;
> > 
> > After Hugh alluded to barriers, it seems the read of SWP_VALID could be
> > reordered with the write in preempt_disable at runtime.  Without smp_mb()
> > between the two, couldn't this happen, however unlikely a race it is?
> > 
> > CPU0                                CPU1
> > 
> > __swap_duplicate()
> >     get_swap_device()
> >         // sees SWP_VALID set
> >                                    swapoff
> >                                        p->flags &= ~SWP_VALID;
> >                                        spin_unlock(&p->lock); // pair w/ smp_mb
> >                                        ...
> >                                        stop_machine(...)
> >                                        p->swap_map = NULL;
> >         preempt_disable()
> >     read NULL p->swap_map
> 
> 
> I don't think that that smp_mb() is necessary.  I elaborate:
> 
> An important piece of information, I think, that is missing in the
> diagram above is the stopper thread which executes the work queued
> by stop_machine().  We have two cases to consider, that is,
> 
>   1) the stopper is "executed before" the preempt-disable section
> 
> 	CPU0
> 
> 	cpu_stopper_thread()
> 	...
> 	preempt_disable()
> 	...
> 	preempt_enable()
> 
>   2) the stopper is "executed after" the preempt-disable section
> 
> 	CPU0
> 
> 	preempt_disable()
> 	...
> 	preempt_enable()
> 	...
> 	cpu_stopper_thread()
> 
> Notice that the reads from p->flags and p->swap_map in CPU0 cannot
> cross cpu_stopper_thread().  The claim is that CPU0 sees SWP_VALID
> unset in (1) and that it sees a non-NULL p->swap_map in (2).
> 
> I consider the two cases separately:
> 
>   1) CPU1 unsets SPW_VALID, it locks the stopper's lock, and it
>      queues the stopper work; CPU0 locks the stopper's lock, it
>      dequeues this work, and it reads from p->flags.
> 
>      Diagrammatically, we have the following MP-like pattern:
> 
> 	CPU0				CPU1
> 
> 	lock(stopper->lock)		p->flags &= ~SPW_VALID
> 	get @work			lock(stopper->lock)
> 	unlock(stopper->lock)		add @work
> 	reads p->flags 			unlock(stopper->lock)
> 
>      where CPU0 must see SPW_VALID unset (if CPU0 sees the work
>      added by CPU1).
> 
>   2) CPU0 reads from p->swap_map, it locks the completion lock,
>      and it signals completion; CPU1 locks the completion lock,
>      it checks for completion, and it writes to p->swap_map.
> 
>      (If CPU0 doesn't signal the completion, or CPU1 doesn't see
>      the completion, then CPU1 will have to iterate the read and
>      to postpone the control-dependent write to p->swap_map.)
> 
>      Diagrammatically, we have the following LB-like pattern:
> 
> 	CPU0				CPU1
> 
> 	reads p->swap_map		lock(completion)
> 	lock(completion)		read completion->done
> 	completion->done++		unlock(completion)
> 	unlock(completion)		p->swap_map = NULL
> 
>      where CPU0 must see a non-NULL p->swap_map if CPU1 sees the
>      completion from CPU0.
> 
> Does this make sense?

Yes, thanks for this, Andrea!  Good that smp_mb isn't needed.


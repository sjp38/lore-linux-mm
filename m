Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4693C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 03:23:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A334621B68
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 03:23:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A334621B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FD6F8E0002; Tue, 12 Feb 2019 22:23:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AC698E0001; Tue, 12 Feb 2019 22:23:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29CDB8E0002; Tue, 12 Feb 2019 22:23:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0D708E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 22:23:45 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id j32so746688pgm.5
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 19:23:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=AbbilO3KjCKg7M7hSMfL94Xg/9oX5fEzQBOE1Nvuzog=;
        b=uJ1p++oUNf8Ec7qOPOD5Yaej93kcdS7WTM1X1GRwQXh3N1VqF2Wi7tSqOK3c/yEK9n
         Wh58lwTAxf9q6A2TyOynPsUe4SgzSAKrC85RY9fdBA2KUVGdHmyYn5jDf2mkDtWQnrLi
         tDNdKVUvPpzpoReDNlOAJiTx0pUnYOTYcTds/MG+cYJpCrc92K2ZG02K6+mGQSkhiYgf
         9f5dlHCSvzJ+kraEu31x2aOAh0vNJGPOa8xzS8qGBHflipm0xe8fSYfSQaViMltIRogU
         9L8HvCu/ybtr45NW3Eyrm/lxCPiSkIAPzyh/jX2hMuqcRUyRB0vCWU1ZJPRfr5VPdkfv
         m21Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaNgP4fGlRnsHdZ0EGTNwFe/eqww4uECFoFS1WaspaCo4PlwI9J
	rsAzLaynOz6CNbpiAcAPU0+nzUJX0/RBPMN6V+d5NwZq6MF66MR2UswXwvU2T5C6JZJEIgjtSrX
	8jdwW57SJRjnuAxhNhpWDLgoSBa/35jRPfTsy41C7Vv+LUBOpvHenURpZoLb7oDrK8A==
X-Received: by 2002:a63:ae0e:: with SMTP id q14mr990156pgf.151.1550028225560;
        Tue, 12 Feb 2019 19:23:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY0rh8IIfn4yCQ5iG73T1O8lFYUYcIWXRgraMMSht//HdB7B3QLHXuO2/lmx72AEuzPqOXZ
X-Received: by 2002:a63:ae0e:: with SMTP id q14mr990106pgf.151.1550028224672;
        Tue, 12 Feb 2019 19:23:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550028224; cv=none;
        d=google.com; s=arc-20160816;
        b=EQD3K/o/oL0AZQh2L5efd6bKOYfDnvx3zSjLXc8HZYM2LxUbgokRQd1YsifTuAQxRe
         8/2HbeBR5nJmaBg5jqkVPzOEFZlDo8ybTK+jfWcqy4GL2oPAB+QSeWtmPTNgOCkR+JvD
         bNRx9HgoTZgv7sgpNfcuyCZWZpL7nDsmvugcDX/YiQOdX5NP7uAEJYBuW9Ml3I119an1
         namCDdu1dPZoxYVvo/8jcGygNP0lYgjs51Y2xW/LO1I71lDq7mph+cXN8sTpTBBJ8Uu2
         2envaiC2Ch/taTo2dC6mgFIJw3dOMFxhdbjDMEvgewb99c3bEbiN60S836a2TApv0gXA
         YoHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=AbbilO3KjCKg7M7hSMfL94Xg/9oX5fEzQBOE1Nvuzog=;
        b=jqR0mJRjgNLSwvOCIPwwjKYfsA4BG6f2hKHV3HGlkZ/pO/zH2N1VxDPmzPSK+nPabr
         AZZlBQ5rViCORPHuvd219IQ55+XIRDmaxSG1JM1iR+B2IISLQE0OilLedlYxBxJDeaEQ
         IyOnMpsKdSnemZ93nZKt5E4QCBkfFqIwW42tcVh4YZvq9hMjZ9JpZbLjs9HpmdWD7D5e
         ZDQ5FM1i+ERdE+imiOwaiO7CFyFdozmz+YN6WTmyZL81bz8A03FjM1iUv+GXqVquwBrc
         s1VdYTtEdhPk//kDGBrF5fXVEPN4gYyR7RptfYiwIvXrbrY8J97xUu8G1Q3nIfHiX4FS
         Kwvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id u4si13215727pga.91.2019.02.12.19.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 19:23:44 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Feb 2019 19:23:43 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,364,1544515200"; 
   d="scan'208";a="115769977"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by orsmga006.jf.intel.com with ESMTP; 12 Feb 2019 19:23:39 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrea Parri <andrea.parri@amarulasolutions.com>,  Daniel Jordan
 <daniel.m.jordan@oracle.com>,  Andrew Morton <akpm@linux-foundation.org>,
  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Hugh Dickins
 <hughd@google.com>,  "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
  Minchan Kim <minchan@kernel.org>,  Johannes Weiner <hannes@cmpxchg.org>,
  Mel Gorman <mgorman@techsingularity.net>,  =?utf-8?B?SsOpcsO0bWU=?= Glisse
 <jglisse@redhat.com>,  Michal Hocko <mhocko@suse.com>,  Andrea Arcangeli
 <aarcange@redhat.com>,  David Rientjes <rientjes@google.com>,  Rik van
 Riel <riel@redhat.com>,  Jan Kara <jack@suse.cz>,  Dave Jiang
 <dave.jiang@intel.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap operations
References: <20190211083846.18888-1-ying.huang@intel.com>
	<20190211190646.j6pdxqirc56inbbe@ca-dmjordan1.us.oracle.com>
	<20190212032121.GA2723@andrea> <874l99ld05.fsf@yhuang-dev.intel.com>
	<997d210f-8706-7dc1-b1bb-abcc2db2ddd1@linux.intel.com>
Date: Wed, 13 Feb 2019 11:23:38 +0800
In-Reply-To: <997d210f-8706-7dc1-b1bb-abcc2db2ddd1@linux.intel.com> (Tim
	Chen's message of "Tue, 12 Feb 2019 09:58:11 -0800")
Message-ID: <87lg2kid6t.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Tim Chen <tim.c.chen@linux.intel.com> writes:

> On 2/11/19 10:47 PM, Huang, Ying wrote:
>> Andrea Parri <andrea.parri@amarulasolutions.com> writes:
>> 
>>>>> +	if (!si)
>>>>> +		goto bad_nofile;
>>>>> +
>>>>> +	preempt_disable();
>>>>> +	if (!(si->flags & SWP_VALID))
>>>>> +		goto unlock_out;
>>>>
>>>> After Hugh alluded to barriers, it seems the read of SWP_VALID could be
>>>> reordered with the write in preempt_disable at runtime.  Without smp_mb()
>>>> between the two, couldn't this happen, however unlikely a race it is?
>>>>
>>>> CPU0                                CPU1
>>>>
>>>> __swap_duplicate()
>>>>     get_swap_device()
>>>>         // sees SWP_VALID set
>>>>                                    swapoff
>>>>                                        p->flags &= ~SWP_VALID;
>>>>                                        spin_unlock(&p->lock); // pair w/ smp_mb
>>>>                                        ...
>>>>                                        stop_machine(...)
>>>>                                        p->swap_map = NULL;
>>>>         preempt_disable()
>>>>     read NULL p->swap_map
>>>
>>>
>>> I don't think that that smp_mb() is necessary.  I elaborate:
>>>
>>> An important piece of information, I think, that is missing in the
>>> diagram above is the stopper thread which executes the work queued
>>> by stop_machine().  We have two cases to consider, that is,
>>>
>>>   1) the stopper is "executed before" the preempt-disable section
>>>
>>> 	CPU0
>>>
>>> 	cpu_stopper_thread()
>>> 	...
>>> 	preempt_disable()
>>> 	...
>>> 	preempt_enable()
>>>
>>>   2) the stopper is "executed after" the preempt-disable section
>>>
>>> 	CPU0
>>>
>>> 	preempt_disable()
>>> 	...
>>> 	preempt_enable()
>>> 	...
>>> 	cpu_stopper_thread()
>>>
>>> Notice that the reads from p->flags and p->swap_map in CPU0 cannot
>>> cross cpu_stopper_thread().  The claim is that CPU0 sees SWP_VALID
>>> unset in (1) and that it sees a non-NULL p->swap_map in (2).
>>>
>>> I consider the two cases separately:
>>>
>>>   1) CPU1 unsets SPW_VALID, it locks the stopper's lock, and it
>>>      queues the stopper work; CPU0 locks the stopper's lock, it
>>>      dequeues this work, and it reads from p->flags.
>>>
>>>      Diagrammatically, we have the following MP-like pattern:
>>>
>>> 	CPU0				CPU1
>>>
>>> 	lock(stopper->lock)		p->flags &= ~SPW_VALID
>>> 	get @work			lock(stopper->lock)
>>> 	unlock(stopper->lock)		add @work
>>> 	reads p->flags 			unlock(stopper->lock)
>>>
>>>      where CPU0 must see SPW_VALID unset (if CPU0 sees the work
>>>      added by CPU1).
>>>
>>>   2) CPU0 reads from p->swap_map, it locks the completion lock,
>>>      and it signals completion; CPU1 locks the completion lock,
>>>      it checks for completion, and it writes to p->swap_map.
>>>
>>>      (If CPU0 doesn't signal the completion, or CPU1 doesn't see
>>>      the completion, then CPU1 will have to iterate the read and
>>>      to postpone the control-dependent write to p->swap_map.)
>>>
>>>      Diagrammatically, we have the following LB-like pattern:
>>>
>>> 	CPU0				CPU1
>>>
>>> 	reads p->swap_map		lock(completion)
>>> 	lock(completion)		read completion->done
>>> 	completion->done++		unlock(completion)
>>> 	unlock(completion)		p->swap_map = NULL
>>>
>>>      where CPU0 must see a non-NULL p->swap_map if CPU1 sees the
>>>      completion from CPU0.
>>>
>>> Does this make sense?
>> 
>> Thanks a lot for detailed explanation!
>
> This is certainly a non-trivial explanation of why memory barrier is not
> needed.  Can we put it in the commit log and mention something in
> comments on why we don't need memory barrier?

Good idea!  Will do this.

Best Regards,
Huang, Ying

> Thanks.
>
> Tim


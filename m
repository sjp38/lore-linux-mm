Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BF12C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 06:47:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B67D20836
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 06:47:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B67D20836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBB698E0015; Tue, 12 Feb 2019 01:47:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B43CB8E0013; Tue, 12 Feb 2019 01:47:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E51B8E0015; Tue, 12 Feb 2019 01:47:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 577F38E0013
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 01:47:14 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id z4so1413345pln.12
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:47:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:user-agent:date:message-id
         :mime-version;
        bh=dxka2ebCeOo8H/vzCDPMXSQ7l0a7wedUTMkx8XIDOGk=;
        b=prnCzeBhmtt2fucThv8IGrKHYQkTNQXDDkXhxEd194vrbBZqN9RKz537cE84uJ4dDy
         r2f47ut4dJIBXq7psheBBGnIhBETHhPvK/ONT7ID3PnG1NMdKV84Oarec/c7TpNdkppx
         i8txspQ6dnb/Gz4HaUXzGLK4KS6yQnAkSV3hkovKe7HGuFQ7aq5EnNU9fFSYZI+BZMfp
         zwNmAXue2MZEjA7NyqvDeMrAq1Cb7D3rj3CUrGbAeX/+ZzbLM6DUUaRBhkisH9lIGXgL
         trdODHJLmbCfesS0gvuj9FmzBvwiUi4bwkw+yB51cbIpO/oeWspw5Cd5LVlgKhdFVLPn
         tPzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAua8YzO1f4ont6dC6him4TtyLpunwXW3jKQrh++GaM+bzpuVsCLw
	0o/MVSAhJz+bIxgkAzoQfA+g+5GYsw8SOFYHNVXl8ODUKvyj8lQx3jgwLlr9VpISxIufb7PgIVR
	d7XLhPNM2M6giLK6Q1jD9IwQOFionquDV51tor2KP5kRrudHDsgDGkeatw5eMWyNj5g==
X-Received: by 2002:a17:902:f24:: with SMTP id 33mr2472587ply.65.1549954033949;
        Mon, 11 Feb 2019 22:47:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaB/3Hj53rfK260NJTYY6Ed5M2UH/5KUJYOgtAjXNMgnAwhngv6OqizRkCBz4/uS45qjEzo
X-Received: by 2002:a17:902:f24:: with SMTP id 33mr2472547ply.65.1549954033285;
        Mon, 11 Feb 2019 22:47:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549954033; cv=none;
        d=google.com; s=arc-20160816;
        b=xmSMSBp3z3q+stgt3ZRtR3wnog667mIJRLYIZF5qklWmakWBJmcahGbNMyyGzyoFew
         FtSvZnlLAke0DH4E7TokOHNc7PUVuUDphJspV/kFnLCYejl2Xtx+i2qvDRZ0Ng75/nnE
         I2VbsjWoaAXRVwgR5yfKdkVDbNRsOfL0ACek/ZYXgzUY0bnzSEPzDF23JhF6nE/bfPov
         TtntoGtQL0jQeBHGRh5Hz4D1yIzgRZDMv9UeY3x/XHiziUw//HheyiyA0jI6QDXXmCd6
         QAAg3ZFJInzbUKxaAMX96BjHJLDT8hW51iua4TMYmpCJ1SKba7Dcdz6oTl5UnHYj741y
         JRNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:user-agent:references:in-reply-to
         :subject:cc:to:from;
        bh=dxka2ebCeOo8H/vzCDPMXSQ7l0a7wedUTMkx8XIDOGk=;
        b=ReVB4AIDMZjE0fIHe3qtu3DPLl6CdOrC1zQH5a3yrjnuh30ZL9XR2uAHBOMcajQIV7
         WqyQ3s7cTnj0+od7d/HZtICD7at1scydbKdrx78MpihLq4iqiM/EW7mp0BNZkLMoMVe8
         IblEBd7tA1KjWY+w1bAWmp7FXriHIqWMHvrrcjKJ9AymZbD40GCTgcy4MpQ58Un9FWJf
         c2N/8sw+T644WW2Z9hk7ZosV05YIxKbWgq6rMnP4V0DCNnnf1Gchqvio0/p1Qe4hn2Sk
         qTbk5XC0UproTA3dw77TFjbUkRs7E2/HIi5a72SYevUriTL9XRPwAef4ksjuaNj7DnuO
         9JPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z17si9370294pgf.267.2019.02.11.22.47.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 22:47:13 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 22:47:12 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,361,1544515200"; 
   d="scan'208";a="142670170"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by fmsmga002.fm.intel.com with ESMTP; 11 Feb 2019 22:47:09 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Andrea Parri <andrea.parri@amarulasolutions.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,  Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Hugh Dickins <hughd@google.com>,  "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,  Minchan Kim <minchan@kernel.org>,  Johannes Weiner <hannes@cmpxchg.org>,  Tim Chen <tim.c.chen@linux.intel.com>,  Mel Gorman <mgorman@techsingularity.net>,  Jérôme Glisse <jglisse@redhat.com>,  Michal Hocko <mhocko@suse.com>,  Andrea Arcangeli <aarcange@redhat.com>,  David Rientjes <rientjes@google.com>,  Rik van Riel <riel@redhat.com>,  Jan Kara <jack@suse.cz>,  Dave Jiang <dave.jiang@intel.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap operations
In-Reply-To: <20190212032121.GA2723@andrea> (Andrea Parri's message of "Tue,
	12 Feb 2019 04:21:21 +0100")
References: <20190211083846.18888-1-ying.huang@intel.com>
	<20190211190646.j6pdxqirc56inbbe@ca-dmjordan1.us.oracle.com>
	<20190212032121.GA2723@andrea>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
Date: Tue, 12 Feb 2019 14:47:06 +0800
Message-ID: <874l99ld05.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Parri <andrea.parri@amarulasolutions.com> writes:

>> > +	if (!si)
>> > +		goto bad_nofile;
>> > +
>> > +	preempt_disable();
>> > +	if (!(si->flags & SWP_VALID))
>> > +		goto unlock_out;
>> 
>> After Hugh alluded to barriers, it seems the read of SWP_VALID could be
>> reordered with the write in preempt_disable at runtime.  Without smp_mb()
>> between the two, couldn't this happen, however unlikely a race it is?
>> 
>> CPU0                                CPU1
>> 
>> __swap_duplicate()
>>     get_swap_device()
>>         // sees SWP_VALID set
>>                                    swapoff
>>                                        p->flags &= ~SWP_VALID;
>>                                        spin_unlock(&p->lock); // pair w/ smp_mb
>>                                        ...
>>                                        stop_machine(...)
>>                                        p->swap_map = NULL;
>>         preempt_disable()
>>     read NULL p->swap_map
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

Thanks a lot for detailed explanation!

Best Regards,
Huang, Ying

>   Andrea


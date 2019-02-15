Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8A2CC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 07:50:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71E1A20836
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 07:50:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71E1A20836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0F4C8E0003; Fri, 15 Feb 2019 02:50:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBFDC8E0001; Fri, 15 Feb 2019 02:50:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD6E98E0003; Fri, 15 Feb 2019 02:50:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 97DED8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 02:50:27 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id g9so6901414pfe.7
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 23:50:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=d36AgB+FqbIk/ltA0COgY/2J/z0AkXVW2tCe9o8bRF4=;
        b=UFIyo2Og0OZqPfPkg7fsAPeBq2IBGeKh435VMk8fFBGUL7GVlJDbhbC/aw3pnUB7bM
         HTYqpUzKg5N6YQmAzGcJqNsXreDzKiYg1q/CaVYjftiQra/HetIcZSPTrMOElt+Un5Gn
         YIw2fU/97SMjd5oXS13zje0AE6v7ENXOw6Q70V2U6paLKjN8XQqUycKGMtg63kUpfYoJ
         zmeVzZ9Ofnb4ZON4ZIAAqUqRkhpb7vZ2yfcbLdWJzm6zOoU4MsqBkL8gGMwIWi1KZ1P3
         69RkpR8IO78qoelNnrzSoh1fTAu7E7wUigG/ncy682vAtQcdGGeBWAy7ZemFFoaCjRw3
         csUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubypKcWBSZUpf0RTEQkUHsNY4lWYbBEtYvpGbuFvU4Ue47JgRaR
	wQvqretus+2O7vyyH76lta5uCmzaDQ1N1cLJxNRWIUQEuEXkvZOw1LMkD7wjj/FcHfBHL5GmFIJ
	/2p8CIV+YiOFbyX+B4zWvR1n5/uVsheJf1wxzDCrIX0N2EZ7XOHQ+5/CYJLx/GPUhDg==
X-Received: by 2002:a63:5a5e:: with SMTP id k30mr4166641pgm.345.1550217027272;
        Thu, 14 Feb 2019 23:50:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZrHyJ3129dLTgKU9NxvqxDizchE73//iLvzElQSklbKcCZxX5gxcdFg0tca9p9oOTrCI/o
X-Received: by 2002:a63:5a5e:: with SMTP id k30mr4166593pgm.345.1550217026572;
        Thu, 14 Feb 2019 23:50:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550217026; cv=none;
        d=google.com; s=arc-20160816;
        b=XdCuiSP1k6H3dXcVxChHGhX8K0j4wdxo55GKPKfdMEL/ZwAHInrT2hl5eJVGI327i6
         UNWuQf1GnSGQtfILBgayvtJKZj3cDUVXHvdkWi3rQ41h2O6vQWbVzAXEkOiPnZ2BjAC3
         rP8UaZHp49Usj1UqJPaVm8U5RrjLBbTWs3hccGUUTjx6ePR7n/ucWdYx2mXbFPivuRcE
         pZcMYRKbRkglzuWkw26K+6tLagdSYBEQLaS0sgHBIGq5F2mxbcF0Uc22G7AOBGXNPQ9C
         PMlWVdhkJ03R4yU8GBx2DroV02FOSATxCJ9FnH3tFHmbx0bvpxn3h7XO7O0FUSqqW8qV
         eQFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=d36AgB+FqbIk/ltA0COgY/2J/z0AkXVW2tCe9o8bRF4=;
        b=L3uMxblE2B3Rc9Z9Yko7ot/qXKO5b8toeaZT/1548MDQbTM/0WHM4d7rX5Dklruy85
         0xxXsWbnkSRqnC08Ld5UiZrrVNdpNsuA+Dal1Y8uedY3MHuJwtJLI9iQmhsY3mOWyh46
         VfYomw+pnWUlgfxBcmlufZ54H5qBZ5wrgtbGEp6ykzAiFKQElLzihQaXMZ027CEknZeH
         kitGzn/rQigkG8CHoYaGkRmSRfPnB3qxGVH3vZy/RyXAPwMI/tIh/9UW0Tfwhci7wC0t
         wn2Jpz9jsqIPRd55eX8q9uITMIpT1hqEvrGpwmWnge4ETexpho7ZBWZZ3v0qIWxgMkHk
         tKrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r135si2993979pfc.123.2019.02.14.23.50.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 23:50:26 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 23:50:26 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,372,1544515200"; 
   d="scan'208";a="126685015"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by orsmga003.jf.intel.com with ESMTP; 14 Feb 2019 23:50:23 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,
  <linux-kernel@vger.kernel.org>,  Hugh Dickins <hughd@google.com>,  "Paul
 E . McKenney" <paulmck@linux.vnet.ibm.com>,  Minchan Kim
 <minchan@kernel.org>,  Johannes Weiner <hannes@cmpxchg.org>,  Tim Chen
 <tim.c.chen@linux.intel.com>,  Mel Gorman <mgorman@techsingularity.net>,
  =?utf-8?Q?J=EF=BF=BDr=EF=BF=BDme_Glisse?= <jglisse@redhat.com>,  Michal
 Hocko <mhocko@suse.com>,  David Rientjes <rientjes@google.com>,  Rik van
 Riel <riel@redhat.com>,  Jan Kara <jack@suse.cz>,  Dave Jiang
 <dave.jiang@intel.com>,  Daniel Jordan <daniel.m.jordan@oracle.com>,
  Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap operations
References: <20190211083846.18888-1-ying.huang@intel.com>
	<20190214023805.GA19090@redhat.com>
	<87k1i2oks6.fsf@yhuang-dev.intel.com>
	<20190214214741.GB10698@redhat.com>
Date: Fri, 15 Feb 2019 15:50:21 +0800
In-Reply-To: <20190214214741.GB10698@redhat.com> (Andrea Arcangeli's message
	of "Thu, 14 Feb 2019 16:47:41 -0500")
Message-ID: <87mumxa3sy.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <aarcange@redhat.com> writes:

> On Thu, Feb 14, 2019 at 04:07:37PM +0800, Huang, Ying wrote:
>> Before, we choose to use stop_machine() to reduce the overhead of hot
>> path (page fault handler) as much as possible.  But now, I found
>> rcu_read_lock_sched() is just a wrapper of preempt_disable().  So maybe
>> we can switch to RCU version now.
>
> rcu_read_lock looks more efficient than rcu_read_lock_sched. So for
> this purpose in the fast path rcu_read_lock()/unlock() should be the
> preferred methods, no need to force preempt_disable() (except for
> debug purposes if sleep debug is enabled). Server builds are done with
> voluntary preempt (no preempt shouldn't even exist as config option)
> and there rcu_read_lock might be just a noop.

If

CONFIG_PREEMPT_VOLUNTARY=y
CONFIG_PREEMPT=n
CONFIG_PREEMPT_COUNT=n

which is common for servers,

rcu_read_lock() will be a noop, rcu_read_lock_sched() and
preempt_disable() will be barrier().  So rcu_read_lock() is a little
better.

> Against a fast path rcu_read_lock/unlock before the consolidation
> synchronize_rcu would have been enough, now after the consolidation
> even more certain that it's enough because it's equivalent to _mult.

Yes.  Will change to rcu_read_lock/unlock based method.

Best Regards,
Huang, Ying


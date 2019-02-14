Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F25DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 21:47:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E74CA217F5
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 21:47:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E74CA217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C1FB8E0003; Thu, 14 Feb 2019 16:47:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6717E8E0001; Thu, 14 Feb 2019 16:47:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 562348E0003; Thu, 14 Feb 2019 16:47:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 280E58E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 16:47:48 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id e31so6961315qtb.22
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 13:47:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=o37Y+f/1VXVMWondogstLZO0MYD+7tXS7P2EG+VyVC8=;
        b=Sh9+6kvHgjkaUl58aLcGnUVFY+iXlEjpYuzirlYgmJyOAg3OjLE7eGTytYecRa3XFd
         ZytgEbLOrH+joei2mix6IUeS/3aaz8pRpfPBuCkd0cbJ0L1pBxeLU4VAS58L+Rzh18Ji
         fbOLYjyEAxIWFaloX+PikiELJAMsQcjlGluL59vMsJN++KEaoHRvT82G6j0sghD5Uxkh
         6ydZJXYrlimOszDfLvLspwcUU7nQTKi8V602ymgXKTVMDlojcyULypdBMLmxxdWF8lW7
         W8/w5shPyYULV8UJbXu5GW90apYKm3hEHMbgKqrYYwIGgaHCMT5h5/zp7tJLzrzew+9U
         wLuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaQCPri9A0ixhrrGvQVi6yfAMcRaptlBGLvwMRBsH80cFyp6cWe
	vNDldedIDY9+Pptk/8SULnpROuqoC1NC3lnaEpWRXthZZu+1Uu887VWBjFn653l4D0pl6G12VxD
	wgIEcGAvex7y6EhmDsese85HBCciDNOFfLDykZa9fuLXGtt53MC59R562xYzpFUhlvg==
X-Received: by 2002:a0c:c192:: with SMTP id n18mr4618050qvh.99.1550180867964;
        Thu, 14 Feb 2019 13:47:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbLSf8AIjUs6kMkZ7B5qq+vafMDvi9zILgAnW/EARnTHEpaHET7xYsLyDDeGvA1uYZQYkeW
X-Received: by 2002:a0c:c192:: with SMTP id n18mr4618032qvh.99.1550180867469;
        Thu, 14 Feb 2019 13:47:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550180867; cv=none;
        d=google.com; s=arc-20160816;
        b=QPpp9IIiG3A5FZoxxdHmyFSi2G9sgpYHxoQHzmg6QlPdkjR4p9TZCAoCOPuio6WbtP
         Gm9oPmEOd80tGfa3+Z/p32u8QurGy83wrOyGIDCXWbgQGeZxW/tfaYlRxAhQYbbOt/V/
         KnGTcwd3clPoFbBx0XJLC+IHPoEj/2Of32kuQaVH/guL4rDJ1Nh4T6PAd2B2Ps1/cjVI
         t4LcKEFLme30YeiwT/hdPHLyQhjyjhSCbhLRqSKEgglKghKrz7Zf2RL71JG6Q9a0A23z
         i6zp8uu1wQj/39YN9Y4c7h+0jYrM/2mN9UIHEFz1z73OrHXmpGcqF12TWVEW1CcLCyYK
         nZXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=o37Y+f/1VXVMWondogstLZO0MYD+7tXS7P2EG+VyVC8=;
        b=i55M29jolpp/6vYKI/5LWeKNVQVo8mMhj8V05YSbJYns+bNcnVkia3ONadXLVHnBha
         EijWljASBd8qT2XFlhT6N3SVhOhM6dEK995GwIDWp7G8+cuXmRR1CJpmTleoaGW0YqTM
         D941eUFdZLoN9LopQJ0R65QSCrtjmP8hpvF/P/bHPB11B+ewDbA5G4l1YhNXYiLO5zG5
         vRRMMc9rATZDABLmi/GWfrrfTpghZkqbtsWgUWajdYzkXuLEmZLKTop52fr6LJk3a7n2
         w+1fz1VcrdZjv3PntyZdwwu2Wo7tY1sY1lfHOEXwayxMpFAXIYJywxRjgpwa897faVAg
         p6NQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o54si1401268qtb.191.2019.02.14.13.47.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 13:47:47 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 92CBDC058CAD;
	Thu, 14 Feb 2019 21:47:46 +0000 (UTC)
Received: from sky.random (ovpn-120-178.rdu2.redhat.com [10.10.120.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A208E600C1;
	Thu, 14 Feb 2019 21:47:42 +0000 (UTC)
Date: Thu, 14 Feb 2019 16:47:41 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	=?iso-8859-1?B?Su+/vXLvv71tZQ==?= Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Jiang <dave.jiang@intel.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap
 operations
Message-ID: <20190214214741.GB10698@redhat.com>
References: <20190211083846.18888-1-ying.huang@intel.com>
 <20190214023805.GA19090@redhat.com>
 <87k1i2oks6.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k1i2oks6.fsf@yhuang-dev.intel.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 14 Feb 2019 21:47:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 04:07:37PM +0800, Huang, Ying wrote:
> Before, we choose to use stop_machine() to reduce the overhead of hot
> path (page fault handler) as much as possible.  But now, I found
> rcu_read_lock_sched() is just a wrapper of preempt_disable().  So maybe
> we can switch to RCU version now.

rcu_read_lock looks more efficient than rcu_read_lock_sched. So for
this purpose in the fast path rcu_read_lock()/unlock() should be the
preferred methods, no need to force preempt_disable() (except for
debug purposes if sleep debug is enabled). Server builds are done with
voluntary preempt (no preempt shouldn't even exist as config option)
and there rcu_read_lock might be just a noop.

Against a fast path rcu_read_lock/unlock before the consolidation
synchronize_rcu would have been enough, now after the consolidation
even more certain that it's enough because it's equivalent to _mult.


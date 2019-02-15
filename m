Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26B9EC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 06:34:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE63821872
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 06:34:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE63821872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22B148E0002; Fri, 15 Feb 2019 01:34:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DB648E0001; Fri, 15 Feb 2019 01:34:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F15F8E0002; Fri, 15 Feb 2019 01:34:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C5D1A8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 01:34:18 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id j32so6159795pgm.5
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 22:34:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=XG8sfyht1gwrE+E8u9cdD7JOliNPbclHvWhTkHUulmU=;
        b=BMiK0jw4KoxYnXWWy0vmfxxq2pjvOVPl51NF1Jh2Lo2oqyHYWAON8y1bQrS4RZoDQg
         UAB+6pbdCjUXBiUMSrTApCJ6kvSXNbMpB7C4o7pXj+j8FbTC9Uc7R0JI2Stfiec6irV6
         Z3BNZRjaJ/NwKCZaaIKGVAQ4xDrn38OOKGoVVuQOqsAwNzz8+54XeUALOrcvkKEA95CW
         I9/vjIt3OvwqvmJxrNaZKs+256BhtFhybrq11tNLMpCodu8yK7A27VIaJNsQ31fON5CP
         g0bUdtFGOu5QETZgMJ8FZUTTj+wJdulbYpD3L+Sry6fytNa1m3/8+M5XsTSpxu+99R5t
         rdrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubNXJ/3tRpbg31TIbyiEvd3UHh/TjemnoE5ryCiv7xrNNXGCYnZ
	cHel9JnUgCX5x7n2pibdMbkkuLvORUH/RFWP4DewHs/hLowFzJ8gzftQpizdZz/W++3bE+Zm5sp
	S7BBJWPCPbM03fvcP8G8LkPMcfmVZ9bq0oG+E9isG2P3mH0VP1vNu0UHfY8dsrx0GPw==
X-Received: by 2002:a17:902:b681:: with SMTP id c1mr8631080pls.103.1550212458385;
        Thu, 14 Feb 2019 22:34:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbGxS79pt2Qexqy1L8hYApWd5ip4JbgwgYFJQsXJ8FGbbHGsRDlF2bmrEt2KcbI2K5s0Q5K
X-Received: by 2002:a17:902:b681:: with SMTP id c1mr8631026pls.103.1550212457568;
        Thu, 14 Feb 2019 22:34:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550212457; cv=none;
        d=google.com; s=arc-20160816;
        b=GFD9rLKLhn99pK+s+rokgaA5yjPEQUbeSEmAqq1Mwj9u9EmlUnCNWqeZwoPTg+neiR
         iPpT1ZkSHAtOIwpNbpiu1qDTO9+s3nYhBJ4wUw7GmUbTwGc+/Vdw+MKVyGJ1NFJeIQ78
         nXd141QC1rzy1E82eHB0AEWei6oIWA2hbmuPgmA51R2lApmOdru6QuH5idXEPnHagpN4
         e3uEM5COSLNR/IXuW0++BHKkyo0yx+9oBQhETicIaRuR8Yc4+3XurGwVoqXdoq2uRu1F
         xnCfMyysA0Q7vG40GrVn4cUdgH5aw7sZdZMCgVNE1Uv4jJ8eq45obQwdhCI/VZimEXTc
         22cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=XG8sfyht1gwrE+E8u9cdD7JOliNPbclHvWhTkHUulmU=;
        b=vPCqMZRomEdvV53LtL+b6o1SGB51TqgFAq/9ZlmDdmPtqgWAaNfE93cWgT1BI3Sv2+
         FQwWVLEImXYJ+zXqloEgZU/ts+ICVo02ReSTuxLf+KIxD2kL/sRxochqiZNvG78DmMMX
         1zEotGm3pvE8f3pn/PBd7bVl4MqFUFZucTVMYcHlEm0M8jsVa6XYzepnkDMHadPxbRT3
         F17zk22YoxG7ZFIfvddsR8Ti2zOFyMJdk6PjQaral+R54fUhpXDgvFhih1F8/BQzlCy4
         TXGtTlBuHFX2T3AD2Vpodt5Djh1bLTQAAeEXoC32pQUYQV6CQD7jiPpM8bp/DOarCmxx
         iR3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s4si2251212pgh.540.2019.02.14.22.34.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 22:34:17 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 22:34:17 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,371,1544515200"; 
   d="scan'208";a="134502115"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by orsmga002.jf.intel.com with ESMTP; 14 Feb 2019 22:34:13 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Andrea Parri <andrea.parri@amarulasolutions.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Hugh Dickins <hughd@google.com>,  "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,  Minchan Kim <minchan@kernel.org>,  Johannes Weiner <hannes@cmpxchg.org>,  Tim Chen <tim.c.chen@linux.intel.com>,  Mel Gorman <mgorman@techsingularity.net>,  Jérôme Glisse <jglisse@redhat.com>,  Michal Hocko <mhocko@suse.com>,  Andrea Arcangeli <aarcange@redhat.com>,  David Rientjes <rientjes@google.com>,  Rik van Riel <riel@redhat.com>,  Jan Kara <jack@suse.cz>,  Dave Jiang <dave.jiang@intel.com>,  Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap operations
References: <20190211083846.18888-1-ying.huang@intel.com>
	<20190212101316.GA6905@andrea>
Date: Fri, 15 Feb 2019 14:34:09 +0800
In-Reply-To: <20190212101316.GA6905@andrea> (Andrea Parri's message of "Tue,
	12 Feb 2019 11:13:16 +0100")
Message-ID: <87a7ixblwe.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Parri <andrea.parri@amarulasolutions.com> writes:

>> Alternative implementation could be replacing disable preemption with
>> rcu_read_lock_sched and stop_machine() with synchronize_sched().
>
> JFYI, starting with v4.20-rc1, synchronize_rcu{,expedited}() also wait
> for preempt-disable sections (the intent seems to retire the RCU-sched
> update-side API), so that here you could instead use preempt-disable +
> synchronize_rcu{,expedited}().  This LWN article gives an overview of
> the latest RCU API/semantics changes: https://lwn.net/Articles/777036/.

Thanks a lot!  The article is really helpful!

Best Regards,
Huang, Ying

>   Andrea


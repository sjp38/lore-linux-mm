Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C5E9C04AB3
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 00:46:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E2082081C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 00:46:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E2082081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 857F46B027A; Mon, 27 May 2019 20:46:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E1056B027C; Mon, 27 May 2019 20:46:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 681196B027F; Mon, 27 May 2019 20:46:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9046B027A
	for <linux-mm@kvack.org>; Mon, 27 May 2019 20:46:14 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 11so14436790pfb.4
        for <linux-mm@kvack.org>; Mon, 27 May 2019 17:46:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=bE+rooZMEZ++B5MReWbEgBGHcAahTBIpJd9+nFIpA/c=;
        b=Nz41/4K5mlk83e6wLmWeMva90cWqFwGboTJDwD57xt4ZEDlUK5BZg4SCjbmd3LOGxb
         kvljRYZK3LxDF6kO45TbtMSRsB39iH6U/h1d4HQOBTipbkJWm1ip64s1ClkzR8ESDTOY
         w+VMo5pvmBeKbJNCsDJkMitU68g+lD8LHvVhL2Z+K9ow6hbUrXZUDtuhMKkXHLL4KKqr
         5cMHqoQUUt4nKjBySbQdfUp0EuLH+VCfQQTdsNlfaDI5AOzEj3OMYoxVKORI8Ea3D6Yh
         1FtzF1ToQLs/qDCtpGkISxzvOQPoPzzEukKE7MuMZmD4AaF1hrS1cVtySa1XHnnySFvW
         OdjA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX0FZhWDwTrjmIGaJkioofveacm7KrkFl6gzl45MDePO5hQVDFM
	uKPsZv627v0pAsZOfwcnKo5j257/rMaU/kd1slNXZJweBixmkdR32p40fy8sOb/b1wTJAD87uzR
	z0X0xhQlNpXoieV4E9jeDPdrV2dPo0qtw9934EmspQju4ifmZINIrFKY386Xr4A4YKw==
X-Received: by 2002:a17:90a:364b:: with SMTP id s69mr1962996pjb.15.1559004373734;
        Mon, 27 May 2019 17:46:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynU2hfQ81gyijI9ScNElpSvIfFGEy+N/VkrwvbpI6a6hOE9xpNWeM2BUoXrWCoChS5KpZH
X-Received: by 2002:a17:90a:364b:: with SMTP id s69mr1962919pjb.15.1559004372956;
        Mon, 27 May 2019 17:46:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559004372; cv=none;
        d=google.com; s=arc-20160816;
        b=yP+F84ZU6PO6WD4+K12LAta7UERxGnuvYXlPj/CWTLgWicIPnXRi7RHd0L9q49d/zj
         3qW7cVLzXx80jcZAbybJ1cA2UaI64dQoycrkbeXw71lOmqtdup4lw0Gj6e6ddc+KgoPb
         QBIKWc9W0JJ6Vaqv2b0nNYVdp+Kn/04v+I7vdr5QLlmx1LkJbU0AuuUzO56Xw/nmKpQw
         N1+Mnwtci+666W81fG/asnJTdh0LrSBMn6jqOydnIte0Na8FYxoQrj108Aqg51N5rJRB
         ztwm2g3HAawrIakxeVTJp8GI+INVEtjpv9OG34uZP5rv4h8TCOat10eOG7u8yFnV1deO
         6HPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=bE+rooZMEZ++B5MReWbEgBGHcAahTBIpJd9+nFIpA/c=;
        b=o0ty9Tk9wX8A3BB5ZYscxemyI2E+iY/TfaVfN+g8sISN0IQudGCa/iOSpGMRTXchID
         uz058RPM+45BwoM8EM2qRph5OfiQ5SYbW6cNCUTYO0pR19YKros4CUA8ET0p+RZDboiY
         vNLipXgKOecRBEbS7un/OteJOijKuEl/dQTqqCD9rjRAUSvK9Go9x1ZVqifDFZKdCYdQ
         fJk9KsC0kUl6YrAWLpC/10rfiKp7wcqDGCeymrR20d0Ktu0BF0w+cREgLyAiCF9H4nFO
         gbnZwf7JJg8Fd4LLWsg3K8lodALe5ssCdys8ZhmLKPOruaBUbUhb/F1Y444Fqr0TyoTL
         uegg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id t1si18835036plr.74.2019.05.27.17.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 17:46:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 May 2019 17:46:12 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga007.fm.intel.com with ESMTP; 27 May 2019 17:46:09 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Hugh Dickins <hughd@google.com>,  Minchan Kim <minchan@kernel.org>,  Johannes Weiner <hannes@cmpxchg.org>,  Tim Chen <tim.c.chen@linux.intel.com>,  Mel Gorman <mgorman@techsingularity.net>,  Jérôme Glisse <jglisse@redhat.com>,  Michal Hocko <mhocko@suse.com>,  Andrea Arcangeli <aarcange@redhat.com>,  Yang Shi <yang.shi@linux.alibaba.com>,  David Rientjes <rientjes@google.com>,  "Rik van Riel" <riel@redhat.com>,  Jan Kara <jack@suse.cz>,  Dave Jiang <dave.jiang@intel.com>,  Daniel Jordan <daniel.m.jordan@oracle.com>,  "Andrea Parri" <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm] mm, swap: Simplify total_swapcache_pages() with get_swap_device()
References: <20190527082714.12151-1-ying.huang@intel.com>
	<20190527101536.GI28207@linux.ibm.com>
Date: Tue, 28 May 2019 08:46:02 +0800
In-Reply-To: <20190527101536.GI28207@linux.ibm.com> (Paul E. McKenney's
	message of "Mon, 27 May 2019 03:15:36 -0700")
Message-ID: <871s0j8kz9.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Paul,

"Paul E. McKenney" <paulmck@linux.ibm.com> writes:

> On Mon, May 27, 2019 at 04:27:14PM +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> total_swapcache_pages() may race with swapper_spaces[] allocation and
>> freeing.  Previously, this is protected with a swapper_spaces[]
>> specific RCU mechanism.  To simplify the logic/code complexity, it is
>> replaced with get/put_swap_device().  The code line number is reduced
>> too.  Although not so important, the swapoff() performance improves
>> too because one synchronize_rcu() call during swapoff() is deleted.
>
> I am guessing that total_swapcache_pages() is not used on any
> fastpaths, but must defer to others on this.  Of course, if the
> performance/scalability of total_swapcache_pages() is important,
> benchmarking is needed.

This patch is mostly about code cleanup instead of performance.  That
is, to make the code easier to be understand.

> But where do I find get_swap_device() and put_swap_device()?  I do not
> see them in current mainline.

They are not in mainline, but in -mm tree.  I should have made it more
clear.  Sorry about that.

Best Regards,
Huang, Ying


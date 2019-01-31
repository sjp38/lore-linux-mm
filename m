Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16C21C282D7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 02:48:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D326D20989
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 02:48:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D326D20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 582D68E0003; Wed, 30 Jan 2019 21:48:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5328F8E0001; Wed, 30 Jan 2019 21:48:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 448AD8E0003; Wed, 30 Jan 2019 21:48:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 113AA8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 21:48:39 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id e89so1352648pfb.17
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 18:48:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=cQr3Rh+iRiheWlpjnuOalKdG7HsMusDlIW0xAbYN+RA=;
        b=rGzbgTALsxeobWpU1aI+nx2VOIgB4qbKRDbP7ZfTKbAkELIJ2WGZVXZrQPhqbe7Rt5
         /TIqNC6gYx5kob+1eg8BxcjIpzcGFeyzKnhgH6Px1e3/iiNFPedyzm+VXGDcxaMFw62F
         31SkhieHkH2zA51jffcPJ4rRLrTBrdl3s3ENcI0zqdmmEOliWpzRXXnBzrJrKfmWzpVj
         riRdob/ElQ7j90R8lxeczDW7eT1BHpWSh29vXA48FBtmJvkWjiYZZ6kKUOQJVJAyrdnE
         2g6SIckUANciUSqLz9YtdcyADUxs8GhIjDfnNuuWdVaBAeW0fHoeidv/gtmLiopyZH7a
         hzzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukeXSC9oMvVovcppGUarB7OQFlh9veMT7MiF/DyjjpYOZibG4Vaz
	nJB196SAhwpx3lmmrd+M6iShbH5Opq70a30tZKy8riasZ5jHqveh581qy3ukOCuRJdJCZxnJt5V
	oSSUIr3qSSVlo1PSvkRiVCyB5lCjX8ExMiTHf533I3dGm9qVFH4TfmZHHJDhdshUNtg==
X-Received: by 2002:a17:902:8687:: with SMTP id g7mr32639705plo.96.1548902918730;
        Wed, 30 Jan 2019 18:48:38 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5lgPhwuKlUeuWK7gliYDjY8ejQDIJvNrEWqa5eTgXajCf04lxPjTCQ2NsnDuyGI1k3Bcpn
X-Received: by 2002:a17:902:8687:: with SMTP id g7mr32639663plo.96.1548902917756;
        Wed, 30 Jan 2019 18:48:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548902917; cv=none;
        d=google.com; s=arc-20160816;
        b=MjEl5WuFJshfsBF3uO4npsXxXCx4W5qQcPNACCwBLxCo6PeHceaZfTJKYFSyEHcE8Z
         Ox3QlOX3Lyhp0VKIrJmj2rCzJkEEuP57vOIiMNt3p6EiNMQ9lvIwZgs3W26E8EnAecbU
         gZcvZ+4UiImWkd9JgYby6ZSfvHO4LPM2gl/YqSL8Pa7TIUBWn7ju04UiUxaphXZdrYdu
         j+LHDZ7X24mIZ23OPLdNXIwqw5c6xVAsJ2YD/OW/mb2jP4xdjTuxnKXYoIOnRyL2unvr
         CsvHhbKolSQkcD+MVxP4rRtF7V/9cunR/g6IeDHjCCbnhmieoXltALehKsw0Ewc3nhSJ
         zIkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=cQr3Rh+iRiheWlpjnuOalKdG7HsMusDlIW0xAbYN+RA=;
        b=RsZmofu9J3opKQ2pbOnnwiqYod76GIbLnjQG5QZA7Qk0wePvSm0vSyGC/B1u4Nhczd
         aRv8wLAPx3P3T0LrstAtyKhEhmAC79xIrrTkF5eQjBonSOkJ/Vx6TDluFbg403O5BETG
         9dbwzBMQFe0QJWVS4HDV5oip+FPrVsjtLzoINmG9eaDwjASK/WKihOu/mOgLBpjeyCPS
         hN9FUoy4jpF+CDewaj2JfeJUHOfOCZyvkh+kwUt+a8PvbNQP+WX85Uu7ODAACNEfr7Vh
         UxTA+bJENyA9rZpdja4oqRtuymLPOy6/bjMk4LOX34R1sz6AyCFjAkJYUcVJjGXRAsUi
         0GLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id b61si3471559plb.70.2019.01.30.18.48.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 18:48:37 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 Jan 2019 18:48:37 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,543,1539673200"; 
   d="scan'208";a="140306193"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by fmsmga004.fm.intel.com with ESMTP; 30 Jan 2019 18:48:34 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,  <dan.carpenter@oracle.com>,  <andrea.parri@amarulasolutions.com>,  <shli@kernel.org>,  <dave.hansen@linux.intel.com>,  <sfr@canb.auug.org.au>,  <osandov@fb.com>,  <tj@kernel.org>,  <ak@linux.intel.com>,  <linux-mm@kvack.org>,  <kernel-janitors@vger.kernel.org>,  <paulmck@linux.ibm.com>,  <stern@rowland.harvard.edu>,  <peterz@infradead.org>,  <will.deacon@arm.com>
Subject: About swapoff race patch  (was Re: [PATCH] mm, swap: bounds check swap_info accesses to avoid NULL derefs)
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
	<20190115002305.15402-1-daniel.m.jordan@oracle.com>
	<20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org>
Date: Thu, 31 Jan 2019 10:48:29 +0800
In-Reply-To: <20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org>
	(Andrew Morton's message of "Tue, 29 Jan 2019 22:26:22 -0800")
Message-ID: <87tvhpy22q.fsf_-_@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:
> mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch is very
> stuck so can you please redo this against mainline?

Allow me to be off topic, this patch has been in mm tree for quite some
time, what can I do to help this be merged upstream?

Best Regards,
Huang, Ying


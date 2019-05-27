Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 790FDC072B1
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 13:29:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DA602075E
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 13:29:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amarulasolutions.com header.i=@amarulasolutions.com header.b="WzL1+1C2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DA602075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amarulasolutions.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E993D6B027D; Mon, 27 May 2019 09:29:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E47AB6B027E; Mon, 27 May 2019 09:29:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D36A36B027F; Mon, 27 May 2019 09:29:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85CAE6B027D
	for <linux-mm@kvack.org>; Mon, 27 May 2019 09:29:06 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id o17so2134873wrm.10
        for <linux-mm@kvack.org>; Mon, 27 May 2019 06:29:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=m+dXzPFPF0QC/08N8/jLGXcjGIV+v/pjQg8Lvb1aVuM=;
        b=O5tH6/M7gXW96HUhby+co/0fsVHCu0rfW04yIdUX03N0so7zpX1MCteJMszqPKtHVu
         Seb4GQKF8oFIBwyppRIIRmjn0HQer9xXnb6dw4YVIZRLiOfnUwUAvdY3mlqXCUY93dpZ
         nsWUocied7F9G2tVFdrB6UOHO/h03BELZn0mZM3CFKKQFdvHiBJWV/9PIeISTWpZq5uP
         IGcKNzrniOBM/rt/+768tK6Qz/KMo33AaySasrFkBm/TkkHDapEVhC5fOFUxqHJTc3tm
         r3tBl1CfFLFcRYSTDiTIkr7rRsJzPerc1iMWRewEwGyx9oGb3vR+Z0RiVWdnYjqI7zOP
         bcFg==
X-Gm-Message-State: APjAAAVgA9fkiuNpigxlf2Aj2DJP74UUq1TE4h/7IUWrLmLGJo4b+JAm
	Ocg7uWii6AXa3FAcGFqeq4BPoLRWRoB3GBsQJiAPrb39gWB8SDY8bnH4rBixc+KJQ+6xOpGyP8P
	eR++WsKBkdrm+uoIOMoBqe5Z3mliXc7Fy2V2/q149OdykXUQN7W03e38haZWzPVM63Q==
X-Received: by 2002:a5d:55ce:: with SMTP id i14mr10714542wrw.352.1558963746020;
        Mon, 27 May 2019 06:29:06 -0700 (PDT)
X-Received: by 2002:a5d:55ce:: with SMTP id i14mr10714498wrw.352.1558963745197;
        Mon, 27 May 2019 06:29:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558963745; cv=none;
        d=google.com; s=arc-20160816;
        b=KyrGRUdZF8ZJUqXbY49tanaYzPc+TFTJxaTBnT5g7k9tpB1XBaG7Uc6fDXpqkHDfO5
         yZj++v2DsU2/PlWd2+eMVDF6xMQENgR2l1/xc6jj+FG1ixAnK+vKDSeAxezgI3BpguyA
         bVNZWVx+lBhafKThr6l4UyNzDlMDvJkMV/ESkeFyz+6Wy5709PdO7551kgJ1aT1uh0SY
         D6yACngUnTySWARNzj/DDNHuLRIuWQdi5F+rSRTg/uS83uYq2PtoVErHG/fcJKZrXpko
         S2fuTj8nzWeVKzOwDfe/yx1i+sT9SSlrpXadgpob1ktVEcekXRglPGz9L0+rMmorVme7
         S37g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=m+dXzPFPF0QC/08N8/jLGXcjGIV+v/pjQg8Lvb1aVuM=;
        b=h4MWMUgEAsFNE17rgWPTAkMSNroMoHRfzDIqZuWXaIs3UAAfHz+zd406lcRe7AqVEa
         cltIlQmoE7d3BVrlxS5pWvgZX04xSo3YBo1srnE8HD8Pzz9XTgH1SUQzJUsS3UX+X2d3
         PN+7DsFsvqLldYjwo8JABupXY3W/F4z9tCmYS1cXo+yVil7+JIzSMb521iM+u7nlEjOQ
         VKijjCpUOChtk9rjq2l3qnP9WVjjAa8Mnfw6YdWulrafcDbEUARqxTZ9ahnvdaGKknsz
         NQyqDlzdbAWbEE3KfueOxMX5bNecQZ0jyv6j6RVUckqWPFUxj8EG4Yb9Or7h7dGHygiH
         chtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b=WzL1+1C2;
       spf=pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andrea.parri@amarulasolutions.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h4sor865746wrw.1.2019.05.27.06.29.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 06:29:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b=WzL1+1C2;
       spf=pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andrea.parri@amarulasolutions.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amarulasolutions.com; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=m+dXzPFPF0QC/08N8/jLGXcjGIV+v/pjQg8Lvb1aVuM=;
        b=WzL1+1C2hQtI9ONr/IqYQEZ+4v1XArIttWiAETlxVdn4U0Xd1Gr6peUX1hFoSTulxo
         DOB5jUtmPKC9AOLSl7nkNoLllSdcLbKe/8sQsKDi3f9Ak0liBKjC/S39b3sLyJdkJCc0
         5WKLezBgJUOPDVnZUgdTZyP85Qg4h94tAac+Q=
X-Google-Smtp-Source: APXvYqx3FVL85vZsOLhYUKwWkJDyaB5qlY0duEg6rDcbtKj+K4FAMYFxlrwC4j8WWJveRBfJUvOY6Q==
X-Received: by 2002:adf:8062:: with SMTP id 89mr3791540wrk.97.1558963744716;
        Mon, 27 May 2019 06:29:04 -0700 (PDT)
Received: from andrea (86.100.broadband17.iol.cz. [109.80.100.86])
        by smtp.gmail.com with ESMTPSA id n10sm5377784wrr.11.2019.05.27.06.29.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 06:29:04 -0700 (PDT)
Date: Mon, 27 May 2019 15:28:57 +0200
From: Andrea Parri <andrea.parri@amarulasolutions.com>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: "Huang, Ying" <ying.huang@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	David Rientjes <rientjes@google.com>,
	Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Jiang <dave.jiang@intel.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm] mm, swap: Simplify total_swapcache_pages() with
 get_swap_device()
Message-ID: <20190527132857.GA1429@andrea>
References: <20190527082714.12151-1-ying.huang@intel.com>
 <20190527101536.GI28207@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527101536.GI28207@linux.ibm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> But where do I find get_swap_device() and put_swap_device()?  I do not
> see them in current mainline.

You should see them in the -mm tree:

  https://ozlabs.org/~akpm/mmots/broken-out/mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch

or

  http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/commit/?id=87efc56527b92a59d15c5d4e4b05f875b276a59a

Thanks,
  Andrea


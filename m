Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4672BC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 10:13:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03BE12077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 10:13:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amarulasolutions.com header.i=@amarulasolutions.com header.b="DWfwx5tb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03BE12077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amarulasolutions.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 973DD8E0014; Tue, 12 Feb 2019 05:13:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 924888E0012; Tue, 12 Feb 2019 05:13:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 813728E0014; Tue, 12 Feb 2019 05:13:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8658E0012
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:13:28 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id w4so803765wrt.21
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 02:13:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=g0JsiH41KjwvocfsMp0bTb3XeLXE9iKeGB1xz8dT32A=;
        b=X2gOHi5bD42TbwNJdKOmPB9IG24YjLy271m/m0+k0u34SVF885So/9JTi3WGXRlUU6
         mBqW3xJuLuvmStT5Nj6VRXuK5LNvtQpxSorDKQ4tFyrOhdAeJ1tKB5/t94tnivu9Elg6
         1MPfjhdcg0Zw9as+eGRwXBvKfmYI/THeZCsyr9m7Rlg7L84rlvrXm+qAVIGG+exDl7fJ
         U+lJ68JGSTmXejke88U/4R9kb458kii9gu0eUqRvECjJ+3sQSA8aRzQVo2wsu35M2Kr7
         qUUVubChXeusZqyvoQxkPkOqiLiF8lpydA5+hDAnsJMWZBm21N83VsWQe2i9bqZHc8o/
         ZMog==
X-Gm-Message-State: AHQUAubLSmM0bB98Grd6bVEhzl0ssBxvCk4eydIDZQbfsTmHdGaeuGPK
	0DxT2AtjJUKqYpD+JkNfadwBuLDAQTkYuJrQDy7yladswCdeZhbSmKtnSeQAlCHXbkxQEeF8ujt
	f/QVfXf/XcXVvdZ6RVrsV0lgWy3uQKpUCd+svn/N6C7wQTXV7REXZumfyWVzvXCrAz1l9Bw/I19
	Tyyq3Zr4bqu5TcijzLsLEk6u80XLJfiBh8W7iF6k84iWWl7vIsvsD1dLDveFpys58MyVVKUrjRb
	HXWdVDyk0sek3zcAS88TivOHES/17++IiT7y2ImokM2G81dWm6ZLk0XrvKl0C3aeIoq+qAPa+eP
	uz1vZOZrmE/6emdZbkhrbiRNSJZA3Jm4k0dx365tx/l0iaSUPbg7KCw1a5A5R6DS8gyiAM25KKG
	Y
X-Received: by 2002:a1c:41c5:: with SMTP id o188mr2205714wma.147.1549966407710;
        Tue, 12 Feb 2019 02:13:27 -0800 (PST)
X-Received: by 2002:a1c:41c5:: with SMTP id o188mr2205671wma.147.1549966406946;
        Tue, 12 Feb 2019 02:13:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549966406; cv=none;
        d=google.com; s=arc-20160816;
        b=oRoQ5VXFNuAxQCmHb7AfTbYI64lrNKSd0hSFDmYgRG14cYYFnI84k/FLxfOcZPgrW4
         FvpMsE0mKJxgr4PRNbme+RVIubB+zWONEvGtxgQ30JUFZREt73MpEDa7QXlSy6+/PLWm
         SFTIIJycDvCyTFDH6gCue8wlKZSv3Q3DKHwa14mLBH6YFSC5Lic+38u377XCOHB4Yeqx
         tGMYvKx1pENxNqjsnJE64YTdL7GoqIt5ERz38MTlnAPSJ0BHt9d+me5WzYwyHBVTDB1t
         wlhrMHnHXY4VMLKmml4i4Gh57TLEtejA3pf2/dA+CA+BEwIcZKWHmwferPWRJAdlqY2x
         vTSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=g0JsiH41KjwvocfsMp0bTb3XeLXE9iKeGB1xz8dT32A=;
        b=VohsVFC1u+e9Uj8B+HM0aDs9wClA4W+lEqjWlEgoD4emTFR9aDgPzczQRo0XRZIpvR
         6eE3vBsEKGU6FIyyBDGmPzm/umt5dz0Bn0kio5OKHpsMFI7aGsa+kCWSwzjWb7M/AFUf
         s8qTGLNXDVa8/5zGoDoqMhViUDW/QwmfyUyb25gUg79D3N6AgtfjJ5reN6nFkj698yp4
         iikrbK80j3DN47klR++8MalJmX5K1y/OBIueIyYc0r6IuoA5qknB7Y9q6UJX+kQxqj/W
         zdrDnV4Np+6ZUdCdW1OZqvdigBw3tXuBxirf83dceSGvG973XLny+LNFWjaeD127faO6
         41KA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b=DWfwx5tb;
       spf=pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=andrea.parri@amarulasolutions.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r17sor8015339wrv.44.2019.02.12.02.13.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 02:13:26 -0800 (PST)
Received-SPF: pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b=DWfwx5tb;
       spf=pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=andrea.parri@amarulasolutions.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amarulasolutions.com; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=g0JsiH41KjwvocfsMp0bTb3XeLXE9iKeGB1xz8dT32A=;
        b=DWfwx5tbB6IVo4HIIiFhkNsfJ4SZ6/zDimJNgTlVGK+CvuSgxyZcPuDigAGLkxqqHn
         aFEj3qBL+1KRbmVapS9XSNRwti4AEpOCmAiow73iKHa6A1utJW1qabjNj/+e7aCRWGFa
         mf406VjNtP0kT3H6Yf5OlhFAOfQwD6DmX8RII=
X-Google-Smtp-Source: AHgI3IZPZNArtBqTt7cgQ07OzsRJFORv/tckhbBOEZQDfGJt12ChgEvQA3SGdcEssYqkBT43NTRbSw==
X-Received: by 2002:adf:9dc4:: with SMTP id q4mr2340947wre.330.1549966406403;
        Tue, 12 Feb 2019 02:13:26 -0800 (PST)
Received: from andrea (86.100.broadband17.iol.cz. [109.80.100.86])
        by smtp.gmail.com with ESMTPSA id o9sm1809180wmh.3.2019.02.12.02.13.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 02:13:25 -0800 (PST)
Date: Tue, 12 Feb 2019 11:13:16 +0100
From: Andrea Parri <andrea.parri@amarulasolutions.com>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Jiang <dave.jiang@intel.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap
 operations
Message-ID: <20190212101316.GA6905@andrea>
References: <20190211083846.18888-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211083846.18888-1-ying.huang@intel.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Alternative implementation could be replacing disable preemption with
> rcu_read_lock_sched and stop_machine() with synchronize_sched().

JFYI, starting with v4.20-rc1, synchronize_rcu{,expedited}() also wait
for preempt-disable sections (the intent seems to retire the RCU-sched
update-side API), so that here you could instead use preempt-disable +
synchronize_rcu{,expedited}().  This LWN article gives an overview of
the latest RCU API/semantics changes: https://lwn.net/Articles/777036/.

  Andrea


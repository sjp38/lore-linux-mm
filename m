Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2E2EC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:37:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F34121773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:37:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WbhijUgq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F34121773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 405E36B0005; Wed, 17 Apr 2019 09:37:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B52E6B0006; Wed, 17 Apr 2019 09:37:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CC626B0007; Wed, 17 Apr 2019 09:37:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E8DCA6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:37:40 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id c7so15480987plo.8
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:37:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=aNBp8zZsCedFf/ZARbBZvKowVyAgmvU1Z2npQm6qDvY=;
        b=WztD2viFv+m987FvM+n5+6xPg67eP7zxjpjgPK46KgPa3TOU26iSqVIJYGYGpX/dCB
         pQ5RZVafie5RyPeGDG+AyywPiDAgKNfTk41rqP+oi7Ii031MYCTeb086V98HmTa9um6J
         tdh0ezFHeZm9VkCOJMsZ07JzAv/qXG8CWbOuzz61H2UXih5d8W/FNi0cjnr9sz88d0nc
         6X2qtCPc0HiczpVmUn2Xh+MreslkDmwdFXX9J1J6mdByeysohGnMYeqX8UIf/g6QFHQT
         orcsT+qgF2oYK/yIf2VgdkoH8AqUxCHM02WAfmdLJY2L25l3c1pwAt3awMd4Mpf8b1LI
         /sGQ==
X-Gm-Message-State: APjAAAWMN6Dxr0ujR+Mbl2zj0ea4wKsjN7gcoTvX8EjHbiOnQyCU6a6t
	uXfGKdAndqLjje0VsVH0wKbAqlzc+uo0jFVGMFFP94XCwRXR+xaJ+MBZsx1k5clYkzMkw7v2Xxm
	Yvbmn0fNPp0erpxV2TApOxAeKLbNR8g9SZy4U+81RBLrO2kR3wN4ujxA4Qjsnvf7dmg==
X-Received: by 2002:a17:902:3183:: with SMTP id x3mr89982957plb.170.1555508260516;
        Wed, 17 Apr 2019 06:37:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxd+SVJ+cr8DNW3Ihfbq/UzLETWxjEfWrVsKRMnIeoeMsmkao+IWzVFmaE7O2PGnz4BG9oV
X-Received: by 2002:a17:902:3183:: with SMTP id x3mr89982886plb.170.1555508259872;
        Wed, 17 Apr 2019 06:37:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555508259; cv=none;
        d=google.com; s=arc-20160816;
        b=GSp30hGYNMoPgjA2Q/FOLNFmqw5nUIsYsf9axVAOoUO7levWHWNe3AA4pHHtFrE3I0
         hycdVLFguHl9bURR7FVtj30XEJbxxJVlHiJT6cK4bDvEh/VJ8Pdpd59mvEXxAh3Rche7
         T51GOZv7RsWRcc3rGsyBrrsQDHgUd/qXsQZsGdXJ4CvOU+r4R9Ifha6337eTypHvgr8e
         3r/NFyIkNQf+BO2D+NWfDtIvPymoMiBYMTTF428T2e53MrFJKwkUFudoz59zX8D3LHDt
         rEJC84gszZqcnQtvJtD76enyREsxrKBGxPD6mXjINLFg5tiUEQiHbhosCirOTYbNb/BZ
         JJUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=aNBp8zZsCedFf/ZARbBZvKowVyAgmvU1Z2npQm6qDvY=;
        b=s77iQ0xVLSQqiyFApfdl/uoRs6XWGI5g1vvyZ2TBA41Qg9VCPvPElGn3muTuF2ewtc
         VCljZbo5ydqFpTYGKroCLWtlGHeFMP55T+o5vb7ctQCcqWJayMdU0ZM/ZUSxd94GdCqd
         Z8f+Vv5fv0gEwrqMzlzMXNMVs+hfhWyRQgetN2YQPoXXypn16b17htUACilLWWAVqKVQ
         kurYTeFZD9ZtwTKrR+0R8gEWQQ+kkWE5eFeuIORtq/oTq14GKoavA/caRyirEcydNR+j
         bSMHkCpXHovCBfXi3N+Bd8HufBQDd3vkVyXmQ3+gWZXtxAC8ROinkbc+/ao7RYEGe0yB
         tDDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WbhijUgq;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t14si34085657pfh.87.2019.04.17.06.37.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 06:37:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WbhijUgq;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=aNBp8zZsCedFf/ZARbBZvKowVyAgmvU1Z2npQm6qDvY=; b=WbhijUgqDxk3tSxsB6+3IAGVf
	hnz5NpW/yiYjVgkKR93janCG9tRp6cwa/V6WUT+De6Kno7KfTc5BuO/iGFERNvZWdLLOBmlwFapt1
	DFxPEsaNxlWrc4dyTvI1K2xXCMf3ElwDCglCgunZHWMTk84w9p6Z3rM5+pn9SwUuPSViLTPQxlLmY
	9qWBmrm3Fky+DKKU3Y0lEPe1NQHx3H+/86xx7m/ZBE2y5Av6NijtS0pA6gjft9ohs08MW1l0skMvb
	tpi7OSS14pq2Z1+vRE5gFOBRkv3x1oh5sYWD+tiJSsey8sKaYPPn/yTAlv5fthdreuZri8a2YFy/I
	zKerzYQsA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hGkkf-0006w2-H9; Wed, 17 Apr 2019 13:37:25 +0000
Date: Wed, 17 Apr 2019 06:37:25 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] mm/workingset : judge file page activity via
 timestamp
Message-ID: <20190417133724.GC7751@bombadil.infradead.org>
References: <1555487246-15764-1-git-send-email-huangzhaoyang@gmail.com>
 <CAGWkznFCy-Fm1WObEk77shPGALWhn5dWS3ZLXY77+q_4Yp6bAQ@mail.gmail.com>
 <CAGWkznEzRB2RPQEK5+4EYB73UYGMRbNNmMH-FyQqT2_en_q1+g@mail.gmail.com>
 <20190417110615.GC5878@dhcp22.suse.cz>
 <CAGWkznH6MjCkKeAO_1jJ07Ze2E3KHem0aNZ_Vwf080Yg-4Ujbw@mail.gmail.com>
 <20190417114621.GF5878@dhcp22.suse.cz>
 <CAGWkznHgc68AHOs2WNPARmwMMKazuKXL1R4VsPD_jwtzQeVK_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGWkznHgc68AHOs2WNPARmwMMKazuKXL1R4VsPD_jwtzQeVK_Q@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 08:26:22PM +0800, Zhaoyang Huang wrote:
[quoting Johannes here]
> As Matthew says, you are fairly randomly making refault activations
> more aggressive (especially with that timestamp unpacking bug), and
> while that expectedly boosts workload transition / startup, it comes
> at the cost of disrupting stable states because you can flood a very
> active in-ram workingset with completely cold cache pages simply
> because they refault uniformly wrt each other.
> [HZY]: I analysis the log got from trace_printk, what we activate have
> proven record of long refault distance but very short refault time.

You haven't addressed my point, which is that you were only testing
workloads for which your changed algorithm would improve the results.
What you haven't done is shown how other workloads would be negatively
affected.

Once you do that, we can make a decision about whether to improve your
workload by X% and penalise that other workload by Y%.


Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67C8EC76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 07:00:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4939321911
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 07:00:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4939321911
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B02838E0003; Tue, 23 Jul 2019 03:00:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8BB88E0001; Tue, 23 Jul 2019 03:00:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 905958E0003; Tue, 23 Jul 2019 03:00:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 55BEF8E0001
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 03:00:00 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id t62so12968004wmt.1
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 00:00:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eaDT7tRORutytnqzDJOnt/zF3Osgx1yw34p8tVfTXGc=;
        b=bXt+GaFYZHBVCoXmmxZbSskaDeITZV8i5SD7v4q4HUaRZnQarYmxxnlBPrLfwWp3zO
         bNZfUZZsZz8lOlGi1cbnV2ObBmBtgWnmSk7ScOMNHKYA3wJ2nV7GuZVFudPwc8bkw9zV
         UgonnWsCFVMoNxkaS7BU3nn7QQHvnWtLjQ3JPXnZsyptTs0lgU1K/D83EixJoN6FCNAE
         9u397RyyFVTyvuGD21wVBAkFyUiEviVWV4TJnTHZ1gh8FGYrAk3SPaMcI1XVMtTy1+z6
         YZG+maY0mf2VCPvXxRks3kiMQpbRksK9xHq6yn5OjHRTyQ5YcqUmvnEZgCQIAFIfINB3
         EOWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.230 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAUGvntlA2NWPvV6QVstvSHllc+ETbaKDvsRb41HJd/qYcsyIwUO
	LJ/7FKLIn3DOHlXqvLYgaFfXapX16AV2kkJi2CTOd70DM9toz2UOkzvGFC+yRNI/8um6WyLAFQv
	teX55jXnzojndHI+cI2lSVP/n5mU43WTWyEBkPL8chZIeNfEJ2XFGgRPpibYEstJRxw==
X-Received: by 2002:a1c:9c4d:: with SMTP id f74mr66451645wme.156.1563865199833;
        Mon, 22 Jul 2019 23:59:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4oaq1gQnNosqvdquKdODllCmMCvPGUPGIxKjtzf06mo7vZodOz3oEu4yx7tolrfKaRnQg
X-Received: by 2002:a1c:9c4d:: with SMTP id f74mr66451566wme.156.1563865199020;
        Mon, 22 Jul 2019 23:59:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563865199; cv=none;
        d=google.com; s=arc-20160816;
        b=XHYB25VxMcaYyDDo5ZjFS2PySNHhv0LgvetsfjEw9WiNJiKnj66f5oqjem3BbsnHGy
         j5vPYgvcPyB77CTV0xgl5brIhtceGdogU5G1i3+U/yss1mFDJGV0N00Ik4GI78ifaUd1
         LfBwh9AVr7QKcnhF926/q/+N9UFLqGgsAVdTxYbS4wxUPXbAR/YGdN0F15gqQDYMqFG9
         BX8S6VASMYqkvOwfw84j42+pgH9C+gA6WXRQjDqzDmeZzpShq1xRrBtMUS3OsYnvhne1
         9zetzNUP+d3XvOkKLZ99tTlhDAWOCDpp090Sb/ceBnbPr2vMuquw68Ucv8lTGspc1XL9
         VukA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eaDT7tRORutytnqzDJOnt/zF3Osgx1yw34p8tVfTXGc=;
        b=CB4LeqBmphwtmlaeBt2meUs64u87YRK2ZD5w0kDkSnTp05Q0g67m0y5Fpocy22rhXu
         scPdyC8fkksil6tbW8rHKEPogdplCNS8Wo+JUmDLeOuXEJLg0zxxvOpG1uX7CJqf8Xog
         tAhfTqDUM2Z58XpRaFOnJMv5x1BfwZ1rtishJvJjGrLBxc824Kc0/OVS7GjviNr2oOzZ
         BKSUJwkWUWAsjtNW2V5kBafjBDbpI2hNKXrl0Bc5AAuuIe2lqeV/1OhlD0EiEVkA9OcQ
         sgg+NIJQ8/3briE6wQCT4eE9pzYE0CNSN1RXaV+3T/bGLG/U324YP4Db/OCh4iW9ORsE
         fWMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.230 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id w4si41017756wrn.31.2019.07.22.23.59.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 23:59:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.230 as permitted sender) client-ip=46.22.139.230;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.230 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.254.26])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 792BB1C327B
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 07:59:58 +0100 (IST)
Received: (qmail 28044 invoked from network); 23 Jul 2019 06:59:58 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.21.36])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 23 Jul 2019 06:59:58 -0000
Date: Tue, 23 Jul 2019 07:59:56 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yafang Shao <laoar.shao@gmail.com>, linux-mm@kvack.org,
	David Rientjes <rientjes@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm/compaction: clear total_{migrate,free}_scanned before
 scanning a new zone
Message-ID: <20190723065956.GI24383@techsingularity.net>
References: <1563789275-9639-1-git-send-email-laoar.shao@gmail.com>
 <20190722171700.399bf6353fb06ee1a82ffaa5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190722171700.399bf6353fb06ee1a82ffaa5@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 05:17:00PM -0700, Andrew Morton wrote:
> On Mon, 22 Jul 2019 05:54:35 -0400 Yafang Shao <laoar.shao@gmail.com> wrote:
> 
> > total_{migrate,free}_scanned will be added to COMPACTMIGRATE_SCANNED and
> > COMPACTFREE_SCANNED in compact_zone(). We should clear them before scanning
> > a new zone.
> > In the proc triggered compaction, we forgot clearing them.
> 
> It isn't the worst bug we've ever had, but I'm thinking we should
> backport the fix into -stable kernels?
> 

There is no harm in having it in -stable. It may matter for those trying
to debug excessive compaction activity and getting misleading stats.

-- 
Mel Gorman
SUSE Labs


Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55D8DC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:23:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F5622171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:23:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="oqCrtSNo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F5622171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BBA48E0003; Mon, 28 Jan 2019 16:23:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 941E78E0001; Mon, 28 Jan 2019 16:23:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E5318E0003; Mon, 28 Jan 2019 16:23:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 45CDE8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:23:45 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id x64so10297109ywc.6
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:23:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=W3oY1xqZBvb5uVdN7aj7A+kp0VAxPGPd9sCt8NgdAbo=;
        b=XOs0NqT0TiKXX8ej4P1/lUahDNi55PWSySwXAJVvcNgidtSnvD6j6o8dpdl7tNKHyB
         WwgavdLZhk9r4HOx7LGA3Em8hKEEvbyx67q95MoaAhkiDOSOI9rdJq3YdCi2CIdNFOFj
         VVakwZJWrW+Nv4EoUNKh5WhFUdcT1CiLShNY3pCWryYCpLQNxw4aUcpATUmxrc4e+lvy
         bCsUuueZxFC+LBdtwZO/FOHrB7zi9lTth0Pv0d2iPgSdkcieG0+0nfky1qp62r4mGieU
         E/DxQbhrtWR7nIhLw0ZI9HdYzoaNvmH18s0V2Y90+wfx1328nkXtkhGR3dF03MQThJ5w
         zoWQ==
X-Gm-Message-State: AJcUukdxkxNoQGBcy1Jj4b6I9NaLpuLAz3687WP/K6MDXHyFW2bN8rgT
	n4Awy92msSzcZAC94qaUx+HauoqaFEbj1921mG265l/328gCiWxKU8oUmtGDqyRp4F3pSSaBe6e
	t2+5ScAzNjGcjyE9RnJcj9WhQXlZ8k8ogSwSBU0+cNoUgh97H/RveImvRpj7KpBI14I/1OEUXo+
	UfksSC5SXIu52Va0mpEWMxsOL1yvZZsWwjFh8zvNneTiID+B0eNwtr2fnXEaw1oRk6FfHAGcFgK
	Pm4SlyUSDK2DkyD2qkBMdpAYYyWdxrNHPR+prisDT1cZ3zBVRFPl1ywOjD2RgPid92q46YvbiRi
	CU74w0MBkuZQuW4uOJ9LrCf857ML91PiMnl84isrQsnoAXkjJS3N5O2ZPN058CUg6JiaSuyG9bc
	m
X-Received: by 2002:a25:3a86:: with SMTP id h128mr21962554yba.487.1548710624968;
        Mon, 28 Jan 2019 13:23:44 -0800 (PST)
X-Received: by 2002:a25:3a86:: with SMTP id h128mr21962530yba.487.1548710624477;
        Mon, 28 Jan 2019 13:23:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548710624; cv=none;
        d=google.com; s=arc-20160816;
        b=T6AwPGp3b2prSB/cch/s4stBAV8bgjRYLbJ3Jqg7s5PrxWCZ3e72oWUXmfSSWXXy+K
         DhA0PGvLkTBxyVIa/9L63xJ1CKOM8GjI63pf7637hcpjDy+8MR///UK3xQE0GIOTsmGi
         Ic7dh9RkblIEyukyE+yORC+3uy3HR/0c9bJI0Oiv/WWmU14QtNBs7HWjJJ61d8Lr+BkG
         O2O7kNNXqRk/1eO4t33qI2csr3YND12EEgZYDULh2FSvtZknMS21+/riQ7K+GCLLHAeh
         9QY/Wwa32k/T/a6+Utt9wt+muBf/UuWmFeipSOy95sx1d3/uyKrKTsPdH7Sh7RSEqwHM
         EiWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=W3oY1xqZBvb5uVdN7aj7A+kp0VAxPGPd9sCt8NgdAbo=;
        b=W8vKl/gPujpn2CDGTGvWeP9svh/gGRlZhtXWfpIg6QzvLuEKOU7l5vLTAbGHqISqRx
         SirE/BA79P8fI/QIXS4XPzy2MKaz3MNIU8svwGsdahT4PIPfvTnfGstA/Sm56CTuqrO9
         ESqOh7AaeqPtnh/cJIsq4UfcTs3DwQv7IND4tS7Hd4/WsjY2cIOjKbqj33EwOhcmIgIs
         MU4TBXL4ESguDBmVW9WOXtotoF8L1BrKw57sYdr9fSlQfCPLxpM8FbGqIp6AMLX6Yj8Z
         2tQnlxJCiWYPXZ4UXsvp6i1Vd3Xhrc8ZzgGwQt/9OMi3v97MtbVWqoO6UAnu41R+mHUs
         k6Fg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=oqCrtSNo;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k5sor5177102ybp.81.2019.01.28.13.23.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 13:23:44 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=oqCrtSNo;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=W3oY1xqZBvb5uVdN7aj7A+kp0VAxPGPd9sCt8NgdAbo=;
        b=oqCrtSNo/UoV97OKjZDNJhAd+dZJsc6m2M2jTE79zkINKeitFARxb4Btk8w5wssq7B
         h+qJkgT8Wh5LQornKlqF2y08DevoQTqEGNwy2CWiUjGkRrVvVJfmZ3SrSvhz4AAe9rjf
         xHaOrje31Y2ilUukiJ5d/tYwJbwtfrHeychlWKqsWF5VNa3L9VW5lrOIZJsq4uEhSfCf
         tn2PJXCMjbQDTaDl4HdcjgJG0wAEarpQG6+PSpy/edY/weTfjIP5hvaTy54lHvMxq8Xv
         VF45QjoZG8eyKX/PV5Tl70U01SXO5/FUtnaJFguMeHIHI4f/m63YIb3dKWV8O4AVFqwz
         02Sw==
X-Google-Smtp-Source: AHgI3IZB91CNTZqNmQFgMEMFhElan15kyh2hIe9x4vrRvLju7Mge2gp6Kdzg5HgJ6mvedeUDgo2Z/Q==
X-Received: by 2002:a25:7d05:: with SMTP id y5mr3034818ybc.439.1548710624260;
        Mon, 28 Jan 2019 13:23:44 -0800 (PST)
Received: from localhost ([199.201.65.134])
        by smtp.gmail.com with ESMTPSA id s185sm26041014yws.69.2019.01.28.13.23.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 13:23:43 -0800 (PST)
Date: Mon, 28 Jan 2019 16:23:42 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com,
	axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com,
	mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org,
	corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [PATCH v3 4/5] psi: rename psi fields in preparation for psi
 trigger addition
Message-ID: <20190128212342.GC1416@cmpxchg.org>
References: <20190124211518.244221-1-surenb@google.com>
 <20190124211518.244221-5-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124211518.244221-5-surenb@google.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000140, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 24, 2019 at 01:15:17PM -0800, Suren Baghdasaryan wrote:
> Renaming psi_group structure member fields used for calculating psi
> totals and averages for clear distinction between them and trigger-related
> fields that will be added next.
> 
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>


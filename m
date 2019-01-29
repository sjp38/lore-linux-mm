Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E065C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:46:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA14720882
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:46:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="CdwiNsJ2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA14720882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D9D98E0004; Tue, 29 Jan 2019 14:46:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 861138E0001; Tue, 29 Jan 2019 14:46:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 729A98E0004; Tue, 29 Jan 2019 14:46:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 452998E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:46:20 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k90so26134408qte.0
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:46:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=TX/9avdHlGwF5c9r30Zg4tBc/DaARBymNwmK8ffgcbk=;
        b=ZKGlusBLd8rQh9idEa88F1JrO518rTHyze3+C4wl3thg2w3QXlPzvVsxAKcAyie4MG
         nJ76yCTMPYe1/+gz5/1z2TqskIjvMdS4EwGRNt2f8BZAzfDCLsLXD69JqepezNwNytAM
         KMBEyLvnaQ7tY5F30fwxYLubjf00TE4B8Zt1ma6xaMrliILc97IecQW/8Nj4Vdqf6jpG
         PvUuWD17PIRNuXHxxHL4tp9CtL2Di0BTIrlxYaGAiq+YWGWJ2qf4YeNrTHzgee48YFLn
         WBjLE5ImGElOkvBpZcqy9t3Ka9bBDO62C+WVQMJ1SoflEJWcsXC8KSPO9kk3Tyhain/W
         1tFQ==
X-Gm-Message-State: AJcUukdYB6OIFvVm9fctKN6RqqmXgQi0BwarLLXQsAklEKcC+JnZ32UE
	GR+GMNk/jIDKz98hyYUyOm0du4a6nYrYoltVTafwmQJJfeE+P1hpznqR2TXAG1aTzmISskcP6w8
	gfRhetM6Phf9YHq/quva8v7Ta/oCAfn2i77Jmale+mXC7XAbGgoz5uOUsueLAEsA=
X-Received: by 2002:a37:6110:: with SMTP id v16mr25584241qkb.157.1548791180015;
        Tue, 29 Jan 2019 11:46:20 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5V+4+bCOn7GNjj1NmERRYburG1uVdhVN8sudLliDKrPm8SS9HTennvnJwMqt7DRJS4jFE3
X-Received: by 2002:a37:6110:: with SMTP id v16mr25584212qkb.157.1548791179445;
        Tue, 29 Jan 2019 11:46:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548791179; cv=none;
        d=google.com; s=arc-20160816;
        b=B7mE4tXJo7wulrfilD+MfM0NvuKvv+mHORGQRdjFed/Jt929+lK7LCnUuIy8wQ+bMm
         0WSxX0HdULU/2sv/zwMCSsUkJZxFNCEfZG1zKh55FC7p8s9yOAH8l2YL0IlTRR4T0jdz
         uDyickdXHDwOJcKzaZ/BEUSaOWx6AcXwkpArZUUnKdnYyCmOuuQ+x7b7qr8KQ868P47h
         Oztl4n6lAeGHr2Tusmh8bhqhOxtR8nrsXtxYAB6lvRLwspJNfO1f/AZlas5Hp2APecQh
         1brgo/Y/gzFM7KY4cXWQCrjLHb287+hLD4HapNOBYmCfekI/clVDohxZ6nZWoWJMjo+o
         xy9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=TX/9avdHlGwF5c9r30Zg4tBc/DaARBymNwmK8ffgcbk=;
        b=yuxw5odhgbiOalUX0wAo8YxnEz/bqCf+o9bT5uFGock9oyfIi18QSLVhXME+Ej/JV5
         ZHSvtmXbY0YaK5q1xB/71gDb7Wv50viiL5CjEJW4Z40xIFtQpb2dVr2pU3xyV2ArBxEZ
         bq3esDqOwzcNjVe/Fq1obmEcNA7qzTpnpKQM3ZX8a9dyclU8dHf5rNMdUAMpy9Oq2ZQ+
         aiMC3Q+ImwB/bnvAdqHGYw5s62kzrMnnYWd6MisgNJKzYeRU9drX2A9H2OnyPYhBfl15
         044NeS+/HN1cBN+8JllJ/yQD07JHs2IEmW+55YZAjxl4ArDcbT/G/rtjRR+1JZV82QRr
         wAGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=CdwiNsJ2;
       spf=pass (google.com: domain of 010001689b25e696-3caebea9-56c2-46eb-bb49-34e504a123ee-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=010001689b25e696-3caebea9-56c2-46eb-bb49-34e504a123ee-000000@amazonses.com
Received: from a9-37.smtp-out.amazonses.com (a9-37.smtp-out.amazonses.com. [54.240.9.37])
        by mx.google.com with ESMTPS id u24si2022597qtc.86.2019.01.29.11.46.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Jan 2019 11:46:19 -0800 (PST)
Received-SPF: pass (google.com: domain of 010001689b25e696-3caebea9-56c2-46eb-bb49-34e504a123ee-000000@amazonses.com designates 54.240.9.37 as permitted sender) client-ip=54.240.9.37;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=CdwiNsJ2;
       spf=pass (google.com: domain of 010001689b25e696-3caebea9-56c2-46eb-bb49-34e504a123ee-000000@amazonses.com designates 54.240.9.37 as permitted sender) smtp.mailfrom=010001689b25e696-3caebea9-56c2-46eb-bb49-34e504a123ee-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1548791179;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=I1UMXyrSr5C9Wun+bynXFwq9gdNq5eFAuCB5rD45GeY=;
	b=CdwiNsJ2r657gEyE3VWjT8bFrQoX+MIgKoI/inh4198n5xeIYCQIneLveQFCdnky
	czEodJ8+dXQfx098odBEhCc/i/zaImbuMRrakHEu832HISxBrmWPOvqOHzS/BOoWkbv
	om5p9VV4VQadUGmLIRFmfi5sv6EyVmOl654odqWk=
Date: Tue, 29 Jan 2019 19:46:19 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Miles Chen <miles.chen@mediatek.com>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jonathan Corbet <corbet@lwn.net>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    linux-mediatek@lists.infradead.org
Subject: Re: [PATCH v2] mm/slub: introduce SLAB_WARN_ON_ERROR
In-Reply-To: <1548748424.18511.34.camel@mtkswgap22>
Message-ID: <010001689b25e696-3caebea9-56c2-46eb-bb49-34e504a123ee-000000@email.amazonses.com>
References: <1548313223-17114-1-git-send-email-miles.chen@mediatek.com> <20190128122954.949c2e6699d6e5ef060a325c@linux-foundation.org> <0100016898251824-359bbfae-e32b-43a6-8c58-8811a7b24520-000000@email.amazonses.com> <1548748424.18511.34.camel@mtkswgap22>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.01.29-54.240.9.37
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2019, Miles Chen wrote:

> a) classic slub issue. e.g., use-after-free, redzone overwritten. It's
> more efficient to report a issue as soon as slub detects it. (comparing
> to monitor the log, set a breakpoint, and re-produce the issue). With
> the coredump file, we can analyze the issue.

What usually happens is that the systems fails with a strange error
message. Then the system is rebooted using slub_debug options and the
issue is reproduced yielding more information about the problem.

Then you run the scenario again with additional debugging in the subsystem
that caused the problem.

So you are already reproducing the issue because you need to activate
debugging to get more information. Doing it for the 3rd time is not that
much more difficult.

None of your modifications will be active in a production kernel.
slub_debug must be activated to use it and thus you are already
reproducing the issue.

> b) memory corruption issues caused by h/w write. e.g., memory
> overwritten by a DMA engine. Memory corruptions may or may not related
> to the slab cache that reports any error. For example: kmalloc-256 or
> dentry may report the same errors. If we can preserve the the coredump
> file without any restore/reset processing in slub, we could have more
> information of this memory corruption.

If debugging is active then reporting will include the accurate slab cache
affected. The memory layout is already changing when you enable the
existing debugging code. None of your code runs without that and thus is
cannot add a coredump for the prod case without debugging.

> c) memory corruption issues caused by unstable h/w. e.g., bit flipping
> because of xxxx DRAM die or applying new power settings. It's hard to
> re-produce this kind of issue and it much easier to tell this kind of
> issue in the coredump file without any restore/reset processing.

But then you patch does not help in this situation because the code has to
be enabled by special  slub debug options.


> Users can set the option by slub_debug. We can still have the original
> behavior(keep the system alive) if the option is not set. We can turn on
> the option when we need the coredump file. (with panic_on_warn is set,
> of course).

I think we would need to turn on debugging by default and have your patch
for this to make sense. We already reproducing the issue multiple times
for debugging. This patch does not change that.



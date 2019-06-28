Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8289BC5B57A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 15:32:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 497D72064A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 15:32:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="SPfGmsXF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 497D72064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FE378E0003; Fri, 28 Jun 2019 11:32:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AE5B8E0002; Fri, 28 Jun 2019 11:32:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F05C48E0003; Fri, 28 Jun 2019 11:32:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCFD78E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:32:29 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id v58so6451347qta.2
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 08:32:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=AS0whl/EcrrVIjGmsUBB1P/c2zpIOxnuhHXncVKXZDs=;
        b=beykjjht4S+CDsUG9W91HlYkkc2da9l5jSQA+S3gwJYfA0MJBh4QsQ8GqaVBVQTP72
         6wjOgLaK1lyYI88JA6Zkc844fgPcXcpudf/HWqXeUST/E9VxiKOgKEYoY+Klixe2oMgr
         7FtNbfqrSRRrgrW5Kulyy6bANiUQc7tHWUG3XJRMzOTGJWRJmTGAm3UT0Pm48EAZ/s1k
         2PX+yCePhzBtiE+hVCiRbrUPAc6eWoD7MuSXxchXLF6nyXYn+kjYBAGTvvmthSlbiPT/
         nFXxOFpQWVXIDhBbOrkateBdr8q379eOTs8bDcQQf+oB8aUnHCyDafM2aqFqiGzqAFRV
         /w5Q==
X-Gm-Message-State: APjAAAWUsa+WIK17lL1Qvk/KiNEk9Gt/F3Vu0Vr/FgsLMLL7FASZnVVV
	8zmnnmvMAJl8tuqfNA1DYW96CAAxk2+e/B5W7VOIsU41tb7byak0iG94u53cjZbcYDHuZ32HREt
	1cvJ5AGMRsr1PGYF63Nk5hU0N/7xf91P7hWm4hHnqy8pjdSmFSbjmqZl1BjmawpU=
X-Received: by 2002:a37:e10e:: with SMTP id c14mr8872890qkm.54.1561735949634;
        Fri, 28 Jun 2019 08:32:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4TsVa+CWPatXmFXTkb+z742ac4uz53h5LP4q5Yz+ulNpuYvCyGRGjYd7To+mXp2MKRttQ
X-Received: by 2002:a37:e10e:: with SMTP id c14mr8872861qkm.54.1561735949092;
        Fri, 28 Jun 2019 08:32:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561735949; cv=none;
        d=google.com; s=arc-20160816;
        b=Ts1U6K9+UsezqsJqsJzsIzXYtOAy26l1C1zChWwbke9mQMvvtovJD79sw38Y31DUJa
         JcvUYsrqmZePRP8NJzafeOO5JqAAMbXgpNHU0N4lLEL+r9WZTYTocgSd9b66EbGcKwO1
         WCGQ9/K08LHXEUHZSEHB/+/K65oSrQDDVpws0OCGdTPFb5nvvz3kg55jE02/Wbdl8vou
         OcJ0lPdtdxeqgiazWOeLYI5KcVoUXikHrKNqIZVjU1v/sHXLqNNtSfOuTCvc0ZB1zBvr
         LpLWmvoPGd9kLgwlqe9xS/eF7yCxSE4dTHGrsZZfxhmlhmVzsRIpUbdve6aukXJe+G7+
         Cyqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=AS0whl/EcrrVIjGmsUBB1P/c2zpIOxnuhHXncVKXZDs=;
        b=hwqyhr18RxAb6+4Vy9/4u539+Ov6uKjnNSpWpfGeaCSqQkIbhzyI4bXkijfyO9kdt7
         QpNqvIf8QoeihL7bF2AElhlpvlr2hLOF9OVJL/GT/FILRhtilyixlnk4W94ItdsQxdZz
         jE9cuU8gApoK9eza8zM//zdICK/YvzQ7BbhtS92UMpqJ5GqRpBr1Y+aHZibZ0Z6Y6LK+
         hjZITZxD8OJGp0ZxGyRg+52VsTC30TnGp3ZDTwBPCxJ6PHyMb/i/PlW0I0gMBv48R/+6
         BmI5zfHlZrjTgo2HdDV+jESLofFenEkumT32l+o7OClO9i3l2u2l6+dhbkVgIIDHZCON
         a3Ow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=SPfGmsXF;
       spf=pass (google.com: domain of 0100016b9eb7685e-0a5ab625-abb4-4e79-ab86-07744b1e4c3a-000000@amazonses.com designates 54.240.9.114 as permitted sender) smtp.mailfrom=0100016b9eb7685e-0a5ab625-abb4-4e79-ab86-07744b1e4c3a-000000@amazonses.com
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id e11si2216120qkb.125.2019.06.28.08.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 28 Jun 2019 08:32:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016b9eb7685e-0a5ab625-abb4-4e79-ab86-07744b1e4c3a-000000@amazonses.com designates 54.240.9.114 as permitted sender) client-ip=54.240.9.114;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=SPfGmsXF;
       spf=pass (google.com: domain of 0100016b9eb7685e-0a5ab625-abb4-4e79-ab86-07744b1e4c3a-000000@amazonses.com designates 54.240.9.114 as permitted sender) smtp.mailfrom=0100016b9eb7685e-0a5ab625-abb4-4e79-ab86-07744b1e4c3a-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1561735948;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=AS0whl/EcrrVIjGmsUBB1P/c2zpIOxnuhHXncVKXZDs=;
	b=SPfGmsXFLQEBn6h5ufA7w1jky3/Rc5RZWDgWNaiTM/EHlEN3OYChoYEFopmh0TVK
	CsfQ0V2VNWhAZKX5OVGAkkAuAJkc9V4P1tYZ2E+eFutc3svPaXxXsz0EOpjrjpx2KYK
	te37a4g49qMNkC2/MEGlyyhGG40MgUxZQUWAqOFo=
Date: Fri, 28 Jun 2019 15:32:28 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Roman Gushchin <guro@fb.com>
cc: Waiman Long <longman@redhat.com>, Pekka Enberg <penberg@kernel.org>, 
    David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, 
    Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, 
    Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
    Vladimir Davydov <vdavydov.dev@gmail.com>, 
    "linux-mm@kvack.org" <linux-mm@kvack.org>, 
    "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, 
    "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, 
    "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, 
    "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
    Shakeel Butt <shakeelb@google.com>, Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem
 slabs
In-Reply-To: <20190627212419.GA25233@tower.DHCP.thefacebook.com>
Message-ID: <0100016b9eb7685e-0a5ab625-abb4-4e79-ab86-07744b1e4c3a-000000@email.amazonses.com>
References: <20190624174219.25513-1-longman@redhat.com> <20190624174219.25513-3-longman@redhat.com> <20190626201900.GC24698@tower.DHCP.thefacebook.com> <063752b2-4f1a-d198-36e7-3e642d4fcf19@redhat.com> <20190627212419.GA25233@tower.DHCP.thefacebook.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.06.28-54.240.9.114
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Jun 2019, Roman Gushchin wrote:

> so that objects belonging to different memory cgroups can share the same page
> and kmem_caches.
>
> It's a fairly big change though.

Could this be done at another level? Put a cgoup pointer into the
corresponding structures and then go back to just a single kmen_cache for
the system as a whole? You can still account them per cgroup and there
will be no cleanup problem anymore. You could scan through a slab cache
to remove the objects of a certain cgroup and then the fragmentation
problem that cgroups create here will be handled by the slab allocators in
the traditional way. The duplication of the kmem_cache was not designed
into the allocators but bolted on later.


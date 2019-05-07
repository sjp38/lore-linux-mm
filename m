Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5DD1C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 14:21:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64595205ED
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 14:21:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="sovj0pdM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64595205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C8416B0005; Tue,  7 May 2019 10:21:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 851936B0006; Tue,  7 May 2019 10:21:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F20F6B0007; Tue,  7 May 2019 10:21:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 20B8E6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 10:21:52 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id t16so13430120wrq.11
        for <linux-mm@kvack.org>; Tue, 07 May 2019 07:21:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=PyOpCy4lyYtOEiJlgtOCnHvxsUSB08LIoy92RCxb0/I=;
        b=HxcaqoUSuGHiAHxtV91jQ+KcDOr2idlKA0o9zv83nqko2Qutr34YhzFnvBT4ihsjqc
         lI0s20cIiTW0GaFGHXf7HcdwQ6LIY1mhd9GGxy172vXgOiAloX4g1mWew0Gt0Tbsm+pJ
         fRSWIAuZw2VBZ60gaEgxhsfxDnW3Q7lVGrXpnWNdSIVgFYFQnXeUxzvk0SBwY7HIFrRS
         jcvvRzzRRQL6BRNqR9wO4KA7xtuWIjDWrYjIRiUSVm1mn/DcXX9Mv+atW6w3681JibXv
         ezZ/lYo4U9nvlAQHYljq35JpCGpgVLhXQCb3jpPjuA+eWHlkUc4YxtxBdX/hM8xe4VI3
         qrEQ==
X-Gm-Message-State: APjAAAX3EKcBPruK5KeUrgDQ5MNMCm95OHSnnsAY5obzB4xBkYmtoOop
	5RYSzWCbj7GXCtW5/WumvXYX72PyTyPtV0bT1rsybqYQC+fqOo67z5mgIneQhvEc3rvfvjyEbme
	L4M9egE4DxNykIFqmVjgf7h+CbiXXE4YfUTjD9tUNi8r/EWbkRsqceODhP1jOKDnChQ==
X-Received: by 2002:a5d:4ec2:: with SMTP id s2mr22389000wrv.160.1557238911495;
        Tue, 07 May 2019 07:21:51 -0700 (PDT)
X-Received: by 2002:a5d:4ec2:: with SMTP id s2mr22388931wrv.160.1557238910344;
        Tue, 07 May 2019 07:21:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557238910; cv=none;
        d=google.com; s=arc-20160816;
        b=dX9RsqWNpqllLmuSzOCLzLburmB0kVJCHUT5mcig9ZOc+1ZoZyyqn19igV4A6CZhAi
         5oji4JITUdNdN67fBJCGELixR2YMziEhGSCKsoL2QtV3GIVpf9J+97QRUZnXUZDAYHbm
         3e7bueqOldZSAjl+1xG/N/S31oH99I71mn+CNwSBOdbUjTxsAtQCAfIUphGcfdRzHM3o
         2Zt4UTjEsRnKfutAW8Blof8fFen+nZK/sIRulee8qb4XsGtvUNhk0k0PuKnjCvz/7E9D
         f48zCK7oyC0TDfmfFuVzsdqnLb8Gbs86QhQ6kthHQ0YvdOa7Z2mHW2MM2jy7sr+X+ZFg
         snDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=PyOpCy4lyYtOEiJlgtOCnHvxsUSB08LIoy92RCxb0/I=;
        b=li1l6BaL0I9Q6/OS9KQFWb+WrQWqSIuvNRs7BBZdphXG0QLe6LsBuZnL6YxdTA9Sa3
         6/ANdG3CafbydQIwWzQs7XINUQx8n/Qj3wF+8SWhkwz6axhILe17MYs+h/0blTR5zQcx
         3H/+JscObvXDWTTgc8YA+c8DIuGIymWWuKnWuzavBUWtszYqN4pDW5n4xZcd38Y/jlFS
         NNS1ypIWsuTlDziBy2iMvASIjS/uR14SfFSiTs0/IObHVc8a7kRwtP+L6z9qlqKzxQaV
         0/9jDbT7jVuBdzo2NBlxvcjUG9Yg7+yfvqjaPdTzRD24hl1ttaRxwRsdql8ImbVcwjcZ
         n3sg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=sovj0pdM;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z8sor1096465wmk.10.2019.05.07.07.21.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 07:21:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=sovj0pdM;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=PyOpCy4lyYtOEiJlgtOCnHvxsUSB08LIoy92RCxb0/I=;
        b=sovj0pdM+uK6E/RJ4Sg/YbYybkp8hESnILuBCPfuvR8K+hvyIJ29OMCCk13NEeen/E
         3PJatSRof3bqJqL38jf8Y6l7N3WhLkQVi7+fJYunHZFgEBJIUUatbzLTF12Bp8Nj2B5c
         GXvSRyVZjOFr9sFLZeABj69GNduXZqy597GLs=
X-Google-Smtp-Source: APXvYqyiTyDBQDLsr8yrkoz7vrMKkIkq3HgoMT547Klqhg54YydpVBTVbOV25q0GB+RiHsDymYuY4A==
X-Received: by 2002:a1c:2d91:: with SMTP id t139mr22324786wmt.102.1557238909747;
        Tue, 07 May 2019 07:21:49 -0700 (PDT)
Received: from localhost ([2a01:4b00:8432:8a00:56e1:adff:fe3f:49ed])
        by smtp.gmail.com with ESMTPSA id f7sm5796984wrt.81.2019.05.07.07.21.48
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 07 May 2019 07:21:48 -0700 (PDT)
Date: Tue, 7 May 2019 15:21:48 +0100
From: Chris Down <chris@chrisdown.name>
To: Michal Hocko <mhocko@suse.com>
Cc: Yafang Shao <laoar.shao@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/memcontrol: avoid unnecessary PageTransHuge() when
 counting compound page
Message-ID: <20190507142148.GA55122@chrisdown.name>
References: <1557038457-25924-1-git-send-email-laoar.shao@gmail.com>
 <20190506135954.GB31017@dhcp22.suse.cz>
 <CALOAHbAM26MTZ075OThmLtv+q_cCs_DDGVWW_GpycxWEDTydCA@mail.gmail.com>
 <20190506191956.GF31017@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190506191956.GF31017@dhcp22.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000144, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Hocko writes:
>On Mon 06-05-19 23:22:11, Yafang Shao wrote:
>> It is a better code, I think.
>> Regarding the performance, I don't think it is easy to measure.
>
>I am not convinced the patch is worth it. The code aesthetic is a matter
>of taste. On the other hand, the change will be an additional step in
>the git history so git blame take an additional step to get to the
>original commit which is a bit annoying. Also every change, even a
>trivially looking one, can cause surprising side effects. These are all
>arguments make a change to the code.
>
>So unless the resulting code is really much more cleaner, easier to read
>or maintain, or it is a part of a larger series that makes further steps
>easier,then I would prefer not touching the code.

Aside from what Michal already said, which I agree with, when skimming code 
reading PageTransHuge has much clearer intent to me than checking nr_pages. We 
already have a non-trivial number of checks which are unclear at first glance 
in the mm code and, while this isn't nearly as bad as some of those, and might 
not make the situation much worse, I also don't think changing to nr_pages 
checks makes the situation any better, either.


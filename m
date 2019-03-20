Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77CA1C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:15:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3425620828
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:15:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Pl5M/KSg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3425620828
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB7AD6B0003; Tue, 19 Mar 2019 21:15:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D679A6B0006; Tue, 19 Mar 2019 21:15:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7C536B0007; Tue, 19 Mar 2019 21:15:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 946186B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 21:15:19 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b11so777782pfo.15
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:15:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=ECbyCNrL6POmMsnKOC7bnI3ZWNUdHYm5lLii4apClDQ=;
        b=QC5t8pXPt+kjmZtZ3P5NpOOe5lAAnIBUlXuQh0ZPR01pbLr+n9E+jV8ii9dBc2tSdj
         XS+SZACAAriNJ5kvjCTyQlSgOuBM1R95XC4fRQcmrUeg+/ifr7Pwf58uC77UPYb0m/rp
         Du5E++zA1hbzY/xmUZDI/1CdD0thcb8aUhQqwN6yg+lOkaZUg7qpZEZtZO0RejYIvejJ
         zwg5hNhiBd49zgtEvBIqOn63VZfwllzc1nDRfqA2V+4nz/S9nsi4nVj3k4dLMTc8nZuo
         R6ZtFjEDVj4Vkq2DEkfkVH/lHDGFR+8GxNR9UYfxwfVx75cDCLpuWVzQvWd4K8nWYNll
         fQlg==
X-Gm-Message-State: APjAAAVBX543niVx9aCFtwooUfNqnfpJQyHamBreL6mtJFhGkIR4qa12
	SHMiRsAur/Da+xgHzxXznkgE44GbRXwPzVhj/c90/OS9pEs2RWyE14mais89fDTtE+HTiOfI2F0
	jD194W6SaNQFq0k/e2Hqs1BsUEciImbML41PwOTkSkGY+6UNKnomaV8HYehluto+rbQ==
X-Received: by 2002:a63:e752:: with SMTP id j18mr4659685pgk.313.1553044519286;
        Tue, 19 Mar 2019 18:15:19 -0700 (PDT)
X-Received: by 2002:a63:e752:: with SMTP id j18mr4659628pgk.313.1553044518360;
        Tue, 19 Mar 2019 18:15:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553044518; cv=none;
        d=google.com; s=arc-20160816;
        b=wlS8N6yhXuz+ckoq/rosKCv5Buzw+tzrcEPRSfg6IPETccH2Z1nvDSmze1as2Zpdwy
         jS0wfgtOrmg/kh7sq7RUlkRSLVnEXJywCHlZAYfmIzVoUvKwsYsbroJdWgtxADoPHZWk
         DBPDumpfcib22NMCHto1TPtBadT+Uu9Y/c6UBy60h04XBjHuCdody1ePFT3VOwKWBzcW
         kJDPQ8cJJpieoUx0voM9bqUD2IEWpFs9ft1CPs1HKR1MIGPdJ1v4HM1hSZflnhjw9NcG
         ojUJKnSZw6oJMLmZycISeBu3SHArZKq2VOkZaXCceSQUxGv8e2agE0I1qkXqaQqFl6+n
         t9HA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=ECbyCNrL6POmMsnKOC7bnI3ZWNUdHYm5lLii4apClDQ=;
        b=NNlEQykmxrh6RVA69OhusEa6BTgHE1D64PjUWzwv4H6KprdT5bnd73WdbuGl/NXDfJ
         ZkebQ8DCkwLhWUXSA6gYuu44gWbbuiD5juwMJwReAoGuCPBDYePO2KKOqEHiPRl2aBVm
         q+83xheTWAKojArZ86Tc020jKV+wGbYmcTrmIDVXacP1GiSnGqwfbVMNjU6Ly9bAKTTH
         6JhcPvuG2579+Twj3dCcHoo8Z7hzomCqlV+AtvgI83TI7BjkKCbkmRzV2gCe1vzfZchH
         qAOSfdpDx4PT/saH+5fTeTJP+tCGpKmNOv2oDuAFGoacpHFtomYJHJ4gjBkWX5HoEDsF
         V0KA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Pl5M/KSg";
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v35sor849868plg.59.2019.03.19.18.15.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 18:15:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Pl5M/KSg";
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=ECbyCNrL6POmMsnKOC7bnI3ZWNUdHYm5lLii4apClDQ=;
        b=Pl5M/KSgSIiqLFbRFRJNsQDB9iKle66fx9LX4ByieGMWC8SQBtyP2qVxGhltYS52eu
         Cu4JrGQBrPZ21Ba3a0BCPjvBHeuk8s0ihIkCsOiR1vweZEtF8v0RcJ3OGwZOuqCvdkfc
         8aUUsqwVl+eFU87Yt2inqjPTSGmqQv8Bvx6yFstigacWwF/9OzXquTDbu1KqUt7XTW1U
         +eUa/VfxDch+o44zrnfnoOPOJObGYm0s/0ZoAIboXUW84pMFAAeFOJAPXMoxqxf5+fWZ
         TfpLFNCnlqjCpiuxwrB+X0Y3mv6zHqa1bocwXzC2seg7CacojwvvykGFT7Z6oJkXzOgu
         xwjA==
X-Google-Smtp-Source: APXvYqzOiMaKl/du02ONuqlh09I6urwHFacOMjJ61ZMMBO06AiW9KIOBH0tP8AoBI73o/uTgZ0wGqg==
X-Received: by 2002:a17:902:127:: with SMTP id 36mr5139769plb.268.1553044517257;
        Tue, 19 Mar 2019 18:15:17 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id h65sm253003pgc.93.2019.03.19.18.15.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 18:15:16 -0700 (PDT)
Date: Tue, 19 Mar 2019 18:15:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Liu Xiang <liu.xiang6@zte.com.cn>
cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, 
    akpm@linux-foundation.org, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, liuxiang_1999@126.com
Subject: Re: [PATCH] slub: remove useless kmem_cache_debug() before
 remove_full()
In-Reply-To: <1552577313-2830-1-git-send-email-liu.xiang6@zte.com.cn>
Message-ID: <alpine.DEB.2.21.1903191812360.18028@chino.kir.corp.google.com>
References: <1552577313-2830-1-git-send-email-liu.xiang6@zte.com.cn>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Mar 2019, Liu Xiang wrote:

> When CONFIG_SLUB_DEBUG is not enabled, remove_full() is empty.
> While CONFIG_SLUB_DEBUG is enabled, remove_full() can check
> s->flags by itself. So kmem_cache_debug() is useless and
> can be removed.
> 
> Signed-off-by: Liu Xiang <liu.xiang6@zte.com.cn>

Acked-by: David Rientjes <rientjes@google.com>


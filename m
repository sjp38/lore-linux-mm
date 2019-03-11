Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49D37C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:27:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A7142063F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:27:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="NWdY7zDW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A7142063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B7B08E0003; Mon, 11 Mar 2019 13:27:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83E7F8E0002; Mon, 11 Mar 2019 13:27:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 707D78E0003; Mon, 11 Mar 2019 13:27:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 418DE8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:27:11 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id d130so6146795ywc.8
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 10:27:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Qz2LSTrCowWdInggZExDyZ73I7go08ROist2vGyWaAs=;
        b=rrWrCsEoMIb33OUuzSqgwtOuZDdD96PusJqHs9YmnTD8yHhj/j9sYIIu8M4Wk+bGM+
         +m69d5mlJCs45udpmr4EUctdVAfolQy2n4CkN0wl5iaEHtk4zVTd+EgKtfiNjO7Jj7ND
         NAusfWA8mnE3q1UzloBcoA36Lw4zpLqgQnkQrjzKEEb/i5WaM2U7sci9s0zTAP9Vz8n0
         cWz8XTW6Vc4lW4qBrHiQrG60rZOnv1Q5OQjntfG+tduSO8t/bce96c4fjbRo58TMMGmP
         0qOYr+XHqZ8P5oGDb+BPhADUC+orjIGwrGlhKc7QAmiTVmmQ63fwUjtX2VIF2urUEOqJ
         /ZZQ==
X-Gm-Message-State: APjAAAUX52rdbcVmyFBl/ziumu4TrstSIBPnF/PLL1D3gOlyhyxPIaAr
	IZe1kkM2vu0aRcS+pQjvqG1CeEGASDh2M2453BF0lgQFVnxGeLO/lHH+i+QAIcbp0pJi2vCkRpW
	vZq/lbjfa7l0lByirr3pTwfaC0oCmc3G1b7Vnyq+YUEdjxpoZ0hU8Pbk7MDMgQbAolyLFiLKVtz
	SEFODS+y7BOUSj5OcZkaz+lzzaVviA11Pv90Zm+S0nR08tveeexTGxsMZSuGt1EblZ33Pi4OF/1
	ORCvgY/UApUDCQiIwP/YadGup6DAA8w8ugmCHyLz/fWGkbbwo6V8itij+UXYbQAKfgOmAKOPUdF
	vb9bYJVcfT/hpsB3jqWdYjNU8ZeyB7j78hEyuxpt6i5lVhozVNAnrg4H5pt8oOClbMGEG/99Tgj
	j
X-Received: by 2002:a25:3c41:: with SMTP id j62mr28151103yba.263.1552325231057;
        Mon, 11 Mar 2019 10:27:11 -0700 (PDT)
X-Received: by 2002:a25:3c41:: with SMTP id j62mr28151067yba.263.1552325230479;
        Mon, 11 Mar 2019 10:27:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552325230; cv=none;
        d=google.com; s=arc-20160816;
        b=HaJ5BMPZ9eaRa683IAXtzD1l9EUcpKpgVpP7tKXKao7D3SykNzi6r6pIGqbDbjI9B+
         Lqpq3nSW2VeS38wJfz0AturXP5I0wNUIe7zbl4quWRtYyphdXfs/Wqhr+4KkKw4kh5uc
         UVspi4jSXfu7BiJjMmcNzEob/Qoi0nwW7JMgN1B07BZ/bJY5Fl8lC4IfHUqDVqtInljG
         YQoGF0p0ahtoXbZ+blV0InTzy2k+BzKIDMltupYqdSCOb/byMA1y4z2Ao31q3S/qnWBD
         oyKFhq/39dfpFuLPA4leDIJsVVAeYh5kKfWqlUq9TSBPCOCWvdsfOq+BmFMS27kKLkKJ
         MFvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Qz2LSTrCowWdInggZExDyZ73I7go08ROist2vGyWaAs=;
        b=Wpqg05Qg+l9Qk30doeXtqw/Kt3JteFaIY9BvpI58MR2XeZZYx0WrFfC61rk7UOPCBW
         jUrJ2iJN9AnejyOOaJyYX0uN2iZpOy3w587aId0l91cQ5G+NTEMg+6AcPeN/aDBX7fgg
         qwC8q8eAQqGJ+SekA7qswgdYmb8VPDE/TvzUW2HlkfQNjOX24bHDMFupPgAyOLJCF996
         r+zm3k8EJ9DAd0zRCMH21POcbeCPSBDq1V+yHyZbFIQ18FOlvQYhXQQWhNAbvydxRwpF
         SXjz1QW3iH2UKr0/3+TTitGajqsDosTFgDm6LhYaXMqOBZ6iyZgdImihXGnsv1VAxg7P
         bCqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=NWdY7zDW;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p137sor1062635ywg.173.2019.03.11.10.27.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 10:27:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=NWdY7zDW;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Qz2LSTrCowWdInggZExDyZ73I7go08ROist2vGyWaAs=;
        b=NWdY7zDWCp8h9yZobxfgQ2nm/lUfyHtUSPWMw0WZPCqLMsiXwFFwG4vXXTFg0zM8h1
         unavAhXD7dRhuHZJcZ3Jwcs0RjcXY8Mmgl2vHp+VAwVTXffG1I6t/tpSJSoxThbS8u6i
         LVtNP2btdhq77rK/oI0+3cwtBW1cTDHjD2Qq/UEVN6QWW9tfSZyHEDjcO8ch+mE2aefc
         dSPa581sRwD9Qr6UejYn4LR4YfjON0s1xyJ+yB8772cu9PrQJNW0nuf+pEKqR25k7nSd
         OpexzMRyvGlnhplgnBbl5kUzReJz+8fMl0ezJ21NRqkbG4DdzBuYCVLKiF3KETyQyjeY
         8qpg==
X-Google-Smtp-Source: APXvYqyIB/mcNEO7gcVIKGHcUe3j33jfoK4LxvNW6DCh9WkpK2nTDMYfPZRFjTeFxP/5nIDj1ROi0w==
X-Received: by 2002:a81:180b:: with SMTP id 11mr24926060ywy.431.1552325230276;
        Mon, 11 Mar 2019 10:27:10 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::1:3c60])
        by smtp.gmail.com with ESMTPSA id q7sm3187834ywl.68.2019.03.11.10.27.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 10:27:09 -0700 (PDT)
Date: Mon, 11 Mar 2019 13:27:08 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>,
	Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 4/5] mm: release per-node memcg percpu data prematurely
Message-ID: <20190311172708.GD10823@cmpxchg.org>
References: <20190307230033.31975-1-guro@fb.com>
 <20190307230033.31975-5-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307230033.31975-5-guro@fb.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 03:00:32PM -0800, Roman Gushchin wrote:
> Similar to memcg-level statistics, per-node data isn't expected
> to be hot after cgroup removal. Switching over to atomics and
> prematurely releasing percpu data helps to reduce the memory
> footprint of dying cgroups.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>


Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 977B1C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 08:52:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09F162081B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 08:52:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09F162081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95C448E00B3; Wed,  6 Feb 2019 03:52:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90B7A8E00AA; Wed,  6 Feb 2019 03:52:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CA588E00B3; Wed,  6 Feb 2019 03:52:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC5E8E00AA
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 03:52:02 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so2484454edd.11
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 00:52:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=E00e1XZFMbBV671g8gtj9a9UwJlFgEAenIOKTN6GXKU=;
        b=ljQGm4EidT/G6yXBlWBZPu3LrDYr5iEyV4ZHaOpyzlC8nqtXIHL3MbTrOtxCT2o/jZ
         oU8xQBzAmnnUByq0r52pynp6kgOB1HPJoOzzcdT/11X0cfYFpf0VNXIg3yxtpFjTpBlv
         FpN5YMTyYMeqgslcbNVMSVI5/0JzQRiQ74TxyqXWQn5lk35A63deaozqYneTFMs0o8sj
         0K8GzGs0fa3ne/+kvKSDiNKbxyvri3lOu60cM5wLhSlceNw2rWN9F5035MuQPt1JuNoB
         FMENC6gHMrqjKGjF2sRiJvWDJULGDKyPuWKyP3miONDWt3X55vZaE51T3Ms9+nkmIaxo
         raOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.106 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AHQUAuZuX/aIiYI8xhzCxXPvT4xvxukhOzE8Hwu/RThsW4LHV8uoYZYU
	WGbrD+Zsm5h5UxfPx63ZTN92o4j1p3I+v0b6JpJykv580eVLCv98kpJR9vszMX5t4sTB/NkIQrg
	4KLIn+8/ltAAyHDHgMi0Jz7GiUCS66zLuo1t85waFWaCFCI8JgqzXPBSdzF/hV7nJKQ==
X-Received: by 2002:a05:6402:1286:: with SMTP id w6mr7584505edv.53.1549443121736;
        Wed, 06 Feb 2019 00:52:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY4wMTFX6kRuKUERkHY5clsjUs2MZz4zN7t1VQFaGbj7WIjGr2Y77BmD2cKPP79JRHy1GFw
X-Received: by 2002:a05:6402:1286:: with SMTP id w6mr7584467edv.53.1549443120830;
        Wed, 06 Feb 2019 00:52:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549443120; cv=none;
        d=google.com; s=arc-20160816;
        b=KosG/sBBw9e3o4kPq2ALGo+4Z7/MrrzbOxHLCsWxc8nO8kOo0rHEJez9aHcdX961iD
         +dln3jgdmNKL9l8fnEAir/VTRZy7zMFg4Clghf/jkaGhk8t/7lcsGo3HoY5jyCPAj3XV
         dyAFyRYObZMSotYfvFuObUB5Zi3zW2MmovLZMTyiTGyHJb0eH+dzMENAAMTt8Q2nRaeC
         i6AAm4pIGSbg5sMnDOETdQbRK8UpHs0qzMyZfBXtUEmfY/rl+sT9dXFEPm4WzWHbE28M
         iVvMIfz1xKrsPFLtQ9Tx6vbiFSCAFrFiCCZO6QKQTZpsi3ou8EXiyjgHVV1RIXK5419Y
         hPrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=E00e1XZFMbBV671g8gtj9a9UwJlFgEAenIOKTN6GXKU=;
        b=iSAfJ1Me+4TRP+TnZapschTfd81+bwaAb3cfKmlXXqKR+UtpLsAMkYC61tsUN3/w3B
         XHg0gBdhr4HWc2tAPuAzo1XE+g4RMSqGJMj5vLWT+Z3gxMqBAbOpOvJlboFkXpR6GRp3
         OrNT/q4pqE0X2vpE3uSdauHeFh/OOtj/UNmux5Z+w/6dEU4nialETSn/sQizMnsorT2O
         Y6sgPrnV48Bs2+adlTf/LTbvDpciA/eZILgbGIhQ+/74XXqkmTHRcKt+8UFothwoJQqI
         xfd3OfLudNC6BoLZWO4tPzD8Evg+/qjkln8d9YhyW/hVT6Wc/UofZxEZQD2v4XyQq7tU
         3mcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.106 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id e9si319864ejs.279.2019.02.06.00.52.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 00:52:00 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.106 as permitted sender) client-ip=46.22.139.106;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.106 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 3BA131C27B1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 08:52:00 +0000 (GMT)
Received: (qmail 30294 invoked from network); 6 Feb 2019 08:52:00 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 6 Feb 2019 08:52:00 -0000
Date: Wed, 6 Feb 2019 08:51:58 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next] mm/compaction: no stuck in __reset_isolation_pfn()
Message-ID: <20190206085158.GM9565@techsingularity.net>
References: <20190206034732.75687-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190206034732.75687-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 05, 2019 at 10:47:32PM -0500, Qian Cai wrote:
> The commit c68d77911c23 ("mm, compaction: be selective about what
> pageblocks to clear skip hints") introduced an infinite loop if a pfn is
> invalid, it will loop again without increasing page counters. It can be
> reproduced by running LTP tests on an arm64 server.
> 

That was careless of me but the patch looks
correct. Andrew, this is a fix to the mmotm patch
mm-compaction-be-selective-about-what-pageblocks-to-clear-skip-hints.patch

Acked-by: Mel Gorman <mgorman@techsingularity.net>

Thanks Qian!

-- 
Mel Gorman
SUSE Labs


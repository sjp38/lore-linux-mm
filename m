Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C248C43387
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 11:37:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0DFF2173C
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 11:37:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0DFF2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57B718E0074; Tue,  8 Jan 2019 06:37:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52B618E0038; Tue,  8 Jan 2019 06:37:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41B268E0074; Tue,  8 Jan 2019 06:37:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 016628E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 06:37:49 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c3so1535610eda.3
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 03:37:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=TyIFjCVIfnvCmEsvTMJx5nhOlZri72K4gG+paWNle/A=;
        b=o7/ITbGUkgi5vp1O0LrwfK8kcFLZaRuEFABFVi9uBqD/H7UU8C8NzUce7fzfiaxji/
         BKx0+Kt/N4yf8S53IZA3MA/D2r43BznRdbHI17Lxc9aQAXQB+NmCs6xh0+f04i84nSyi
         uxl2Xv3vTfrEQ1o1yJfmtEReUkpjpTCI7CjZtobQQDnNxG6Bi9YK3trJFcxDigzYx4ks
         4APaIn58UZ3ybnDBSMKbttjcGsdFIk7MLJchnsirydKuhCWF8JvXW9JgZ39ksHpcPvMm
         s4t6+Skela79YOW/pC5iNG7WndHw717igcvyps3hAIMPjXQuDtPqamSglRFGmgjg7+nq
         yysQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukcsfO6J53L/V6b1UqNCSxLuqY9OiErXbv3tZC/UB2k7XohEnMlr
	mqBSa7xKLhTnhBUEPk8OnydWlyNWxJzl6QY3tRwTNbHBWyyp5KDwMq188kk4AXHv03MNEJNfFI0
	ruiDKrTe4pH3RJCJBvfzvNDxgU6Plj3DqEUWQlZOP/yHeU0yWSZSEZPSUf/78CfM=
X-Received: by 2002:a17:906:1f99:: with SMTP id t25-v6mr1638880ejr.36.1546947469559;
        Tue, 08 Jan 2019 03:37:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN52SFLWD0oYKO95BeX1z/5XMyyCK/zklVb0JDzvmyOm86Qz47zm8IoYyAu9Bt7Zp+iB0+Xd
X-Received: by 2002:a17:906:1f99:: with SMTP id t25-v6mr1638846ejr.36.1546947468726;
        Tue, 08 Jan 2019 03:37:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546947468; cv=none;
        d=google.com; s=arc-20160816;
        b=JoaQx94fuJB2zKjZPrmDxNRa19Bj7tryyLMQw+3lqUT8L/y7G2AZJf8weL6Dh2XVLs
         lnl4SbB3dXJprE81eW578Ggyq2s8tQj/nvFc3GNAN38yvC/zzedqW/2tOd/6dBxwsqAl
         sj3iGH/8TJJlq8WcFAWAM/DMrfD4ZGkpJIfvPEaRYdDRbMotrnJUYK4DFllu9KlYBXl2
         AO99wK0gUFFWDnbKeN1j3vv4zMI9InaFSi/1FFTUV8w399lXAwyNwS32ILdw9zpkNOXT
         8uRoqBBR0uNHTj6H0sHPlPxolLjrdaGiMgAWfw1DxcbLYLFSWtO1OaTbzDiQZOvT+1s+
         e7Bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=TyIFjCVIfnvCmEsvTMJx5nhOlZri72K4gG+paWNle/A=;
        b=kkdDb2CJ9Y/l0Y812YTG3Ad1zbW/x+kPa/0rOGtKSC04gusZUS2wtjWA7I4CBDzKoi
         V7ne7FN4lqUXDXQh8IoWcS2mYv5uscaEXt8LOobmgiqmkxoK3UIEPow8AVpbRyGwdiud
         hKjOM0hDr0D64UcSuDiv7WQXALk+vdfaHQiy/lnm8gKtFdbr7YGnzxesIa1/4Mtshm5d
         ul+sPSOHvcd4na6qA7dSGSVtReMhiTa0Nu+JKMcAMiBjps9YF9uPhJYhMeE+xmNkZ+Cf
         0TrHKFl/yky7BWuZ5WEIqPfbxKHmjeqHA4z2oBrKwUf7h05Z3fm2jRHuw5NiOBng3GV2
         tgjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l12si1863662edi.230.2019.01.08.03.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 03:37:48 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2D5A8AD6F;
	Tue,  8 Jan 2019 11:37:48 +0000 (UTC)
Date: Tue, 8 Jan 2019 12:37:46 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
cc: Vlastimil Babka <vbabka@suse.cz>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    linux-api@vger.kernel.org
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <047f0582-a4d3-490d-7284-48dfdf9e9471@petrovitsch.priv.at>
Message-ID: <nycvar.YFH.7.76.1901081235380.16954@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <d4846cb2-2a4b-b8b3-daac-e5f51751bbf1@suse.cz> <nycvar.YFH.7.76.1901052016250.16954@cbobk.fhfr.pm> <fb0414ea-953b-0252-b1d1-12028b190949@suse.cz>
 <047f0582-a4d3-490d-7284-48dfdf9e9471@petrovitsch.priv.at>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108113746.eFKL-Ah2-q76kWmoIj8DiLFpRavUkih_EOwtHH_tyjU@z>

On Tue, 8 Jan 2019, Bernd Petrovitsch wrote:

> Shouldn't the application use e.g. mlock()/.... to guarantee no page 
> faults in the first place?

Calling mincore() on pages you've just mlock()ed is sort of pointless 
though.

-- 
Jiri Kosina
SUSE Labs


Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 108BCC282CB
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 00:36:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF3262184E
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 00:36:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="c+/9y65Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF3262184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5776B8E00A6; Tue,  5 Feb 2019 19:36:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 525C88E00A5; Tue,  5 Feb 2019 19:36:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43B248E00A6; Tue,  5 Feb 2019 19:36:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 028848E00A5
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 19:36:46 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 3so3900404pfn.16
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 16:36:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=0HjaLJVDyZEnzBQyRczmKjKjxkVFDZ08SNDZbgZMsI4=;
        b=q3ONlIsssDaThqZEbcRe47EWFCU/WVtfoQUoa5+WHKBtFLxjB65lT2rFEw2YUQeB83
         y4mqvx8x0uC5jpzUINavG6vMz9EQ/viwbsL4e/toXfyw4y+TaHQ13vzGsHrJc+RCceTC
         dsymFeXSBnNyzi1OAFVrAqQlBOOrkCtDiDaO3Fg7uTs7oTtqWlOaV21GhTVpLZdK5tEr
         9AdRu5P1RCQpxffk7YEOPIQjbplb4lBA+Q0VBPW4nVU0zokstbMiGDjnWcRMrGSJPVlR
         8R5pQvTtGJnjZp+EEUykICTMWytAvWwji3hGoTHsEOfAEVBLQmWV1S1Hot9oJevOj0sN
         FEDg==
X-Gm-Message-State: AHQUAuanIVhlXI0k5WEeuImWp6G3IxpJHZTcExDNo4OD0e218czIOG/X
	MMAXzIVfmMePV3IcN1GNwRbbBVxlrkcxTOWA9t1RckR9QDHeB3vfYde8yz0XvF2ekp64MYf3AUJ
	dC2rabk2ogNDOXiS5iOB5zfvT0rzxv4mtExLrHJfPuPrlszEYkoJLjAoBZLD7XUdODQjIJDj/yF
	fnYJUPdaueqbm9gA4DCYzGum5ulDgIzNLGnvrxzCcAplUJoTzs/RA2m9lJX0i22T39KT5TI6n36
	ljsVjN9hFq293Lh7Gp/fnNT7CUVWFICtnMTuGr2g9XIhTMOfgn7T+phUvtIgqcOVGuvdBE5JaCc
	YP+Hi6cmv48XnkjTPro+9TL3GqWQ8El4hgEJXGJY3CpirJBIDYsKcDZQFcLW1KKSBr4xWEk5/1A
	r
X-Received: by 2002:a17:902:8ec9:: with SMTP id x9mr7992986plo.27.1549413405599;
        Tue, 05 Feb 2019 16:36:45 -0800 (PST)
X-Received: by 2002:a17:902:8ec9:: with SMTP id x9mr7992945plo.27.1549413404894;
        Tue, 05 Feb 2019 16:36:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549413404; cv=none;
        d=google.com; s=arc-20160816;
        b=dIpd2pSehmSM3R+EaKHSEnxyizqQcJYL3WN2nqLVNOrHRZSs6JxxKLPYqjdJxNkixx
         GbrVr1UNyZxBibOwmodSgaDdJmOAp3MDdRaxevp3MTwGR9NvzmR37XpAOfcgLBXdHiJl
         zDVrqWgs5CxU5x6KjyWmtDrWHELnztTKjAUswcEobU/u4bnDFXUm9ZRrA0C5L9E4RCrB
         dS7lUsXQ5H2bxiiDTm1/lINnzWvfW1v4FO1DRX9SF/lChhSH5n+9HAI4NQ9kquMOV9Td
         0t2k8iGbznGNajN8dsD/eoj93jdTGdU7QlnyTFUsUnTlbwTcsbHydY8LZO0pyM53V4bX
         qQuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=0HjaLJVDyZEnzBQyRczmKjKjxkVFDZ08SNDZbgZMsI4=;
        b=L8uhydByrySrv6bGrD8zu5RNT7Vidawji5vlyn+eB+U6Hu8a5wKkN+LiLdeGoTO2OJ
         k+PTUzfht2Wn1Q4TOAflI/wqkySDu1l4EKezwxUJ2d7uOjle80MdGB9BR79NVYt7auJh
         6i48cfzFiRaEAmQjN9PFesNNIxztKLyjIPEt1GMdgeqXroyyjsiPEN4Fgf5f57O47C5Y
         /8eHaDs6jNiJzJi2A6oUf5XJ7N49tyDmpVlv26sXODZ2U24OIt6cYiCEOW9wWVjRyeMx
         Nn8aHPUIaYCP5RO9p7XSC5Soj4bX4SAI3s7VRY/mbT0DU9LKf4lH9RFEAeNfnZ4xy2G4
         JoMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="c+/9y65Q";
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1sor6365928pls.39.2019.02.05.16.36.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 16:36:44 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="c+/9y65Q";
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=0HjaLJVDyZEnzBQyRczmKjKjxkVFDZ08SNDZbgZMsI4=;
        b=c+/9y65QyuCG+jHzrXVEqbpFnayVTBSuAsaZZz1lCu9hm8Gr8f7uw26FpBC4wXMmS9
         XaP39FYvOrbbKP7+lZFTLgFitCpZwXW8JqDRuhVTOoCL5Og+U/CDU9fdVZDC+LDuOi/d
         AMgNYOFtcYXqLWfXg4qB1yCACrnc5YPmxMx02fJ5U1+IUR/zJzCMX4+WTvxKIXe44Qiu
         t7NK/dMu5fb2CwLsGHxNmuqzKZWsJvLlcuhBTO4s/x3p/s2XOSbNVpLMkPhOV+1uFcZd
         veWQlHF0IF/KmVQ2g1CTvCLTXRpFop5wHfrsBUrAvcJr8cY4SJ9szTD4c5TmizizalMC
         ncPg==
X-Google-Smtp-Source: AHgI3IapdQYhnX82Nkx2c0dZB6idJYE1b8eoKdqlLLrU43scZZpGKLPGT6fvVtYUtZiT/7pm9Bzo2g==
X-Received: by 2002:a17:902:32c3:: with SMTP id z61mr7876432plb.114.1549413404045;
        Tue, 05 Feb 2019 16:36:44 -0800 (PST)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id 134sm5223164pgb.78.2019.02.05.16.36.42
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Feb 2019 16:36:42 -0800 (PST)
Date: Tue, 5 Feb 2019 16:36:35 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: "Huang, Ying" <ying.huang@intel.com>
cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
    Daniel Jordan <daniel.m.jordan@oracle.com>, dan.carpenter@oracle.com, 
    andrea.parri@amarulasolutions.com, dave.hansen@linux.intel.com, 
    sfr@canb.auug.org.au, osandov@fb.com, tj@kernel.org, ak@linux.intel.com, 
    linux-mm@kvack.org, kernel-janitors@vger.kernel.org, paulmck@linux.ibm.com, 
    stern@rowland.harvard.edu, peterz@infradead.org, willy@infradead.org, 
    will.deacon@arm.com
Subject: Re: About swapoff race patch  (was Re: [PATCH] mm, swap: bounds
 check swap_info accesses to avoid NULL derefs)
In-Reply-To: <878sytsrh0.fsf@yhuang-dev.intel.com>
Message-ID: <alpine.LSU.2.11.1902051618320.10986@eggly.anvils>
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com> <20190115002305.15402-1-daniel.m.jordan@oracle.com> <20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org> <87tvhpy22q.fsf_-_@yhuang-dev.intel.com>
 <20190131124655.96af1eb7e2f7bb0905527872@linux-foundation.org> <alpine.LSU.2.11.1902041257390.4682@eggly.anvils> <878sytsrh0.fsf@yhuang-dev.intel.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2019, Huang, Ying wrote:
> 
> Thanks a lot for your review and comments!
> 
> It appears that you have no strong objection for this patch?

That much is correct.

> Could I have your "Acked-by"?

Sorry to be so begrudging, but I have to save my Acks for when I feel
more confident in my opinion.  Here I don't think I can get beyond

Not-Nacked-by: Hugh Dickins <hughd@google.com>

I imagine Daniel would ask for some barriers in there: maybe you can
get a more generous response from him when he looks over the result.

Warmly but meanly,
Hugh


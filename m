Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D4FEC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 08:09:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63FE120840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 08:09:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63FE120840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0118C8E0003; Thu,  7 Mar 2019 03:09:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDB288E0002; Thu,  7 Mar 2019 03:09:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA50E8E0003; Thu,  7 Mar 2019 03:09:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93E1D8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 03:09:45 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f2so7545197edm.18
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 00:09:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dQgTBfJbNNOuFFyzeEN0ln7xeHkmmD4F9kWlneFGkOs=;
        b=MnWT75T0UuonGXccomr8xnovrNQncph+fit6N4ifw7lhFSkQ9XAGtdt+W9n+IkNknN
         b9Du792q9dbYKcpu7MH/U4lQNYFoEBnDMVbFyg0Wl5k5gDdIk5i6gGYsAgi9pT86oqIe
         dGB34xkDOAkfk7Nk+YzDlFVdD27dxb1LCQ+bCo0XSnLR9XF/+CFwyOVSXGPneLZyc5ar
         VnJ5DbK7bXkDurZ3teJecMZT3JPHAG8r6tliBv1CzwfYg3nPbt1kK6zQ8EZF27FkP47A
         HwVFoERumq7R266d9hm7bU3RK/gt952RV3mHApcwVeJlBgX5Nlg0I3uj44RNePZRuVah
         KKcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAWK/cNt2ELfG5qkM4Wr8TGnUlZ8Y/8ArmUN4pCk+0+jocgUKa1N
	JFQjJTpu0TxQ216S57/DwnVYrVusQbgx8PQMWkxhDZv5xaW34nGMY5o+gpwSH5R/mMtv8XI4NGq
	/0Vit5+EdQpOHr731a9c0aoUANALLfJSE0DuMiba8xzwEH9r6wRh973OAv2x99V2Pdw==
X-Received: by 2002:a50:8529:: with SMTP id 38mr27811267edr.161.1551946184794;
        Thu, 07 Mar 2019 00:09:44 -0800 (PST)
X-Google-Smtp-Source: APXvYqwBaMJWnWfxKSVTYiZIEEvCSOGgnmRH/bvmEQbx5zpekE8xPEWV34bFOSdZmGFLjG9UwY63
X-Received: by 2002:a50:8529:: with SMTP id 38mr27811198edr.161.1551946183457;
        Thu, 07 Mar 2019 00:09:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551946183; cv=none;
        d=google.com; s=arc-20160816;
        b=SVErOhopqYn9i2bDFvmoLzTeawG83eVKQyxqpiuDi/TmPAlP5uo9GUM29xJyL8nD5I
         4ORzSGCrGq8qzPrZhhtLHTZ2VD1Y8sKhLYJ2Z86GPArMa6mm3HGBDfPJZIMfVFt5BxF9
         Ev/u3m5jrAfqSIsJYgYD7zynwQ4Z/jrj5VUjSKkNy4wsAq3AqdvSQy53kulhuAey18Hc
         L5KPgFzcwssO8LBLhV3jbrpJx1iLEGL5NkxpflIX2Pbe/w66NrI5aE3P45st7MDmDCUL
         mu+7fiSPWNUc1pklTg1uOgeFEJsLO/eh2QCnRflhJJHk14hKMs/X0EjxYZTQA4i3LIEe
         KkKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dQgTBfJbNNOuFFyzeEN0ln7xeHkmmD4F9kWlneFGkOs=;
        b=n3Ymf4T2yLZAA1N0BnNkhSBSMOcjkB/y2rDFrOReZtLUBm0KPHaHIF8y+osuuzsME/
         Bakz5xmN8/eVtdm1W/MyLaoWDQOOFSD1CNlf/2dntLJcpyH1aT4VJKxNIEAglWUPHdYL
         lf+ERF/blkql1hQrxV3IMuvQwnHBK1JkoxZAKHHqYRE9j4W1QRBnXGBYPDFW/qDTJkPF
         /GtZqZZauF4KVPaDHcrLZxBx6F8IGaZ7XHvMYOhZB7IK4Ak0ZglgCA9hxWr9bfSeFBXC
         o9QUymVsYIALplfMgkj9HG5CkwUASBOqaesW0Gs8OeAiHuOU3n5ezxxIsnXBIipf7fTW
         aXIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a17si1503374ejj.110.2019.03.07.00.09.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 00:09:42 -0800 (PST)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1D956B137;
	Thu,  7 Mar 2019 08:09:42 +0000 (UTC)
Date: Thu, 7 Mar 2019 09:09:40 +0100
From: Michal Hocko <mhocko@suse.com>
To: Pankaj Suryawanshi <suryawanshipankaj@yahoo.com>
Cc: s.szyprowski@samsung.com, mina86@mina86.com, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: CMA allocation failure and Latency issue
Message-ID: <20190307080940.GL4603@dhcp22.suse.cz>
References: <22ed9e4c-962b-4e8c-8549-d8cca578957f@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <22ed9e4c-962b-4e8c-8549-d8cca578957f@email.android.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


[Cc linux-mm and lkml]

Please do not use html emails, thanks!

On Thu 07-03-19 13:28:59, Pankaj Suryawanshi wrote:
> Hello,
> 
> I am facing issue related to CMA allocation failure of large size buffer.
> 
> I am beginner in Linux memory management. So I need your help to debug the
> issue, 
> 
> I have below questions 
> 
> 1. Why migration failed
> 2. Who pinned the pages, Which process pinned ,how to know ?
> 3. How to migrate pages forcefully so failure will avoid.(not preferable
> approach)
> etc.
> 
> Any help would be appreciated.
> 
> Please let me know if you require further information.
> 
> Regards,
> Pankaj

-- 
Michal Hocko
SUSE Labs


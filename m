Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB3C7C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 22:29:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 537362075C
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 22:29:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 537362075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC9608E00A3; Fri,  8 Feb 2019 17:29:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D83CA8E00A1; Fri,  8 Feb 2019 17:29:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C41178E00A3; Fri,  8 Feb 2019 17:29:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9CB8E00A1
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 17:29:31 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id v25so1877750wml.3
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 14:29:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=4StZFuxn9VZI+kHihc7rQ6sP6XkpNKgDchpXamV2ZIg=;
        b=TCUOwtjCQ9p8d8MPpuLec3rq16AQo7tRZqQw2keVwQCA4cCw3VUAyajYcx2R0Vu1nB
         lsVDFoNsOmuN7NaiS8yjDS7bk6C3E1ZSPYPE6k8zv+bmVLzD56htOAO+KuPULQOVVTEI
         UrQXMmNwrNQAaMuxarMql/zfrKsYZ0z3bWemkura1UaYYmskvPoaqYbEjMrFM/TTe55z
         f04Y3GNqHVpKhrbeEFrhqyV28StgsyGfdRZpiyi8hjHckdJYs1y6kduD/nlGrPihZ2BT
         im+3W/cX59KDPZ833irG1omcB/7O/cJuZ0RMDtWRDsaS2l61rtuBKJRtD2F8aqn1/5rb
         0dGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: AHQUAua+CfndXeKYcwAdJLABJwOl613jTgFUiZa0Tb8w0MSKjMG3OdQ6
	ZdgVt4d3O95uWqffI2zVR+lTwy6ILAocM1qGU/M+HrfsBzs1CgpbIMixteB0cueLKCeracNHcI3
	u1lsWS3n+b46vFFzNvpF7qi8BIJg7rzwMrW+pQxWJhjZjBDVLG9z3rnQDVFOZ6tTMwA==
X-Received: by 2002:a1c:c303:: with SMTP id t3mr517282wmf.94.1549664970989;
        Fri, 08 Feb 2019 14:29:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ2JXnhW/SI4gHjc4VbSrMjpiEwXzFAOeWwwE9Sf5PcMtUYTaoVAp2o83JLGsMt/f/3n4KX
X-Received: by 2002:a1c:c303:: with SMTP id t3mr517240wmf.94.1549664969797;
        Fri, 08 Feb 2019 14:29:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549664969; cv=none;
        d=google.com; s=arc-20160816;
        b=0smXJAqV6tJsVpqAB8Wh6s0RGK6fcmsXNrqvagyqpQQvUoHJICGXCVd6mPeCGwQDtW
         XhJpjEwSDFdXKo+oyV3lYWPAr7Lh9ec02nlI697YXcjIFUtmpz1yki/ycEq4hBW4DhkG
         NTG98ycy6snLKRCebpMuTXX71g/8XKDiixQ1DxjzAj6p8IxeVSLE/yGE6NX4ROL2xG2O
         QjVgpPjkzzRc9JRH0aJkVL/eEYKXRQlfl2YkDESE6I2cQySSsDrPT7Of2hTU6Dj/4jhI
         +k+OYLfNjlNRoaz2eRpK8NUL6wUaCK968RDagrEfwSZ5oWZQaDlUOsqWvTXcqGCTT90U
         ZFWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=4StZFuxn9VZI+kHihc7rQ6sP6XkpNKgDchpXamV2ZIg=;
        b=Be3W5mIiKIKCqiMQPfCdwYS4ihByu/6VJvV160XBAPjtpHowzBOBK8ljMGU/1f8YW1
         WuSl7QJQshVVXe3wb8sBEvzIWJj4EV2TQJTxnyvn4cB7XWIM4bVBGhMgHkHwrlsy0HxI
         nJOS/Gb8N/5Qy5/B86vd4akk/p48lvm80xMzl66XyRJu1LSlxsfePNcPt+TOTeaOjRHX
         Q6LP25IfEMLelqlAV/8OeN5g0mbLMwfBbw4HepnNOFcVDJddb580E/5ISrad4WvjOBHf
         FX+SggHSkvevnKE5yM6HEJh72HUVoHpe1luLwApOVDaH2MpCZA/MuUo8AHVEHxbSyvMa
         f2bA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id z12si2563527wmi.172.2019.02.08.14.29.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Feb 2019 14:29:29 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.91 #2 (Red Hat Linux))
	id 1gsEe8-0001kI-R7; Fri, 08 Feb 2019 22:29:21 +0000
Date: Fri, 8 Feb 2019 22:29:20 +0000
From: Al Viro <viro@zeniv.linux.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Qian Cai <cai@lca.pw>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next] hugetlbfs: a terminator for hugetlb_param_specs[]
Message-ID: <20190208222920.GG2217@ZenIV.linux.org.uk>
References: <ce8d60c2-5166-6c40-011f-4dff8dc25ebe@oracle.com>
 <20190205012224.65672-1-cai@lca.pw>
 <16207.1549643499@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16207.1549643499@warthog.procyon.org.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2019 at 04:31:39PM +0000, David Howells wrote:
> Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
> > Thanks for fixing this.  Looks like a simple oversight when 2284cf59cbce
> > was added.
> 
> I've already pushed a fix for this which Al should have folded in already.

It has been in -next since Tuesday.


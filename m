Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0367FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 19:19:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B289121850
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 19:19:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="kOSEEN/m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B289121850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A56A8E0003; Tue, 26 Feb 2019 14:19:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47A8A8E0001; Tue, 26 Feb 2019 14:19:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3910E8E0003; Tue, 26 Feb 2019 14:19:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FBDC8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 14:19:46 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id e9so11140829qka.11
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 11:19:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=GK4SfxpHL1TW7COE/Vay6DFmtSQUb3SQpYp/sxEryuI=;
        b=as0hJPB9oNWk3aiEoDpQxq6Z+k2aOYB5p9RVeDqAFw3aD8Bw9k+iR8HRh9Tf/KvdB+
         F/J6yhSxBpEn1cebFUSls1a3K0phCsIxxeW++g8L5U7PuLuCX6A0fOBF3iTzXc0I7iqH
         bVjVLf9THbVJlj/Ga2H6EcAOUZFLfxqXd4+fVo+ecpXdzRAS7UpuFG2fs2zdqGpk1Uwg
         L6IJE4FBTPxj/QSGIGhUWQAufZ8+Au9ric4M7jXq2QC5O5/zKyK85ZOO1uPKf4bslF95
         agS8CS3kLggPdltSE1befcjBRxqnF3B+sW2zz3+ntW4rzQainlnj3lH0n6v71tTXldFB
         TQMw==
X-Gm-Message-State: AHQUAubeaxXekxsdBcDzNBP6qnU7Omx1N2jxf/VluHLL5QULsuyBdRyd
	aGliK9T/5u2StsgsA8U3aeYCOm+ljmbcWy2n8rBAVgfHWSMOs6wU6/mdqA9p28TFiLdnaBTLHOl
	muYUISyJ3lDYpjM2WtF2AnogKQ5Xb0EpAZPR85GXT21VRpf4OeFcGsQGo7kfcgRIB1ja8oti1e5
	RRLXTHhTEe7ZnYqLgs4zcUNhY+TtD8m71jq3EBDF7hOK97LxgI8O069liVqSzc7yE8SC66yQbaN
	iYbA87HrU0DBbnYkv2bSaSbV0MOvQs30RDggGVjUDxELyMGfx2sU1HiTQy0VpBnGdnmOK75jsvB
	05xlBF4IHag8zKA7A3Dp0s7jo0NXmPoZw3DapPFMNyQZKAQHpusbur6xT3WBGaADbDkqPbgDCLa
	T
X-Received: by 2002:a0c:95dd:: with SMTP id t29mr19393461qvt.174.1551208785849;
        Tue, 26 Feb 2019 11:19:45 -0800 (PST)
X-Received: by 2002:a0c:95dd:: with SMTP id t29mr19393407qvt.174.1551208784892;
        Tue, 26 Feb 2019 11:19:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551208784; cv=none;
        d=google.com; s=arc-20160816;
        b=Rw3LGc4hQb/rvUAQmItAK9BmjBZOmrcnckJQevLVVugu6wvai8m/BuQ01ws75q9Epc
         wYuDxQk2f1XSFzabZN1l5AWyCMM8axXpF7H4BIofCDzl50C9/UM6j8/bCnHBDzAs2L9y
         E82bVEtK1yaWfRkUYOmTf7vMwEDA10F90+Uw49yq/nnPYWgp0JEq983zw95etPsnGIi/
         okbRh1KSyNG11lj2/8QBd+YlJ2iXAB0Be//tfseC50O5Gp2j91N1NEV7SZ9t806GWOOG
         qZ5ogvHlAvJPw12xFbJkBx1G4io81GWVQIf/48YOQBQ3irbsLludEs/kx/FJIZhP0H9i
         GI9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=GK4SfxpHL1TW7COE/Vay6DFmtSQUb3SQpYp/sxEryuI=;
        b=fQZWQKL12Wv2TZ+/dYOsUncFc/kTlTfYkDRK5YkvBKQ+gnlYX9i/7a2pNMksdPh8Sy
         dCI4efXDu4hGSYc0SrtSLhOMp392w2/iawXojcqpUPNq+VYC36z5KyE8MQhJSCWOZOGh
         ngMg8D92v5XgZvZzMKut3cykssPVc0X7HVcKkrnn+g3YMgsGCczkXY7NreqBqYcjNvLh
         HsnkR0zZLMmnsS9/uAMaQNDm2LIQ6EdMqg7buHoXTtFtXApLpNqpqq8BADRROhjm47Md
         +cKhIaiqq+jdpeVD3+Aboj83sOFRpVWyYqfuD2hZ+NDtU+1SXxa9ZWwcNx1JMWx5d4eg
         afPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="kOSEEN/m";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o54sor16733631qta.57.2019.02.26.11.19.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 11:19:44 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="kOSEEN/m";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=GK4SfxpHL1TW7COE/Vay6DFmtSQUb3SQpYp/sxEryuI=;
        b=kOSEEN/mQlVE842b2oxlZn98OH6UUr8fe9rGWUi2TQmmVz/w+xcm4mJWpjzwIVxSSG
         Z5ZMti6XgNY00hCkh14bfQCXqATzNYLmpoYrwh8gb4kbaRb2dcwl3kQiM+ssCIh1z5//
         b7jIiv2nwipNu6Txhp9IsEmnlYzNp5pAcz3rdl5hin83RLQdm55iFXKEej6OmSC6b0IV
         ZwT49L1caPXLToKrePIImY55Lx0DJQwWUOj3ylYLeKVGHvzxJuOFIXN2Utpuekd7I1aD
         Hz+C+6ALeqy7Rq8kjI3FQ4XjrtJmbIONtjDThoiUMe6xnvnVDYGSkNZLOUG7RA0tsMJA
         jZfg==
X-Google-Smtp-Source: AHgI3IYkmMFLwdW/jIteTI8bQIBaUYBhG9HD5Lwb5XOogW2UFF2P/XIQ56UhBknstq64zReANdUOYQ==
X-Received: by 2002:ac8:22b6:: with SMTP id f51mr19277552qta.182.1551208784518;
        Tue, 26 Feb 2019 11:19:44 -0800 (PST)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id t38sm11324314qtc.12.2019.02.26.11.19.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 11:19:43 -0800 (PST)
Message-ID: <1551208782.6911.51.camel@lca.pw>
Subject: Re: [PATCH] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
From: Qian Cai <cai@lca.pw>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Date: Tue, 26 Feb 2019 14:19:42 -0500
In-Reply-To: <20190226182007.GH10588@dhcp22.suse.cz>
References: <20190225191710.48131-1-cai@lca.pw>
	 <20190226123521.GZ10588@dhcp22.suse.cz>
	 <4d4d3140-6d83-6d22-efdb-370351023aea@lca.pw>
	 <20190226142352.GC10588@dhcp22.suse.cz> <1551203585.6911.47.camel@lca.pw>
	 <20190226181648.GG10588@dhcp22.suse.cz>
	 <20190226182007.GH10588@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-02-26 at 19:20 +0100, Michal Hocko wrote:
> Btw. what happens if the offlined pfn range is removed completely? Is
> the range still mapped? What kind of consequences does this have?

Well, the pages are still marked as reserved as well, so it is up to the
physically memory hotplug handler to free kernel direct mapping pagetable,
virtual memory mapping pages, and virtual memory mapping pagetable as by design,
although I have no way to test it.

> Also when does this tweak happens on a completely new hotplugged memory
> range?

I suppose it will call online_pages() which in-turn call
kernel_unmap_linear_page() which may or may not have the same issue, but I have
no way to test that path.


Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39AACC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 19:14:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE88820840
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 19:14:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mGZu1L4U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE88820840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45DCC6B0005; Tue, 13 Aug 2019 15:14:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40EA76B0006; Tue, 13 Aug 2019 15:14:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 325686B0007; Tue, 13 Aug 2019 15:14:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0092.hostedemail.com [216.40.44.92])
	by kanga.kvack.org (Postfix) with ESMTP id 1121D6B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:14:45 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B0A4F8248AA1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 19:14:44 +0000 (UTC)
X-FDA: 75818356488.18.lace28_639300b4b7459
X-HE-Tag: lace28_639300b4b7459
X-Filterd-Recvd-Size: 3543
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 19:14:44 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id t14so49632534plr.11
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:14:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=DfaDqPxiZMNZIbjsgNm0UGrK6HEhpQEX5jhA59JEvVg=;
        b=mGZu1L4UmgRrdfLrcBt65H8WlaGjVqPf6hmI3iKS3BEHrG04CR+SIlyc/snB3GFpnQ
         vZCBxE8IVRufoJL800Mk/F1qMWc5Vy82hWnKqJ5uLOGHkZSslTpy/S1vyYAXwU94N8l+
         SIRY/lUnbTREy3ktiakmQ06cjhAsoo3dK4YUktGLrXpxEyH1i+g64KRwP07RvO4V90k4
         mH6YqNc25+W3rdO63XMT/YrQNNmwbrLJoU4v1Tz4gOAoeApKAY6qnicKuyH8fl8IhvUU
         C2hsmxZaro3ZW4RcEPv/bftiAQ8aG2hDA2FNDnxnnVtY0M4dIwEwO5JuhFyIHekcERy0
         mLMA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:mime-version
         :content-disposition:user-agent;
        bh=DfaDqPxiZMNZIbjsgNm0UGrK6HEhpQEX5jhA59JEvVg=;
        b=LqHgKPfOx043P/dF3U+c5bqopWaqLcsp0UBFKhAcgCSK7M3XbEIVbU4bga6ZxvxRv9
         YSvSOj0M9OwldjUWIjDeJOfL7HRyTOusI5xOOHbJIcHSHcrq/17l6PENuxcFVNDYl3iU
         m0GSN+/sWjDjKPMXJbjxBJUPLBwWjBR0+nxNdBnmjP+I6Wz8S3u1zZttu0gTE0DGIv5u
         ob4CunDk9kQuXxiVYrGe5+NuXRBODHk1gHy+lrYvnnv4C4oQIwrUB/JevT8W1Btgo67i
         2uRh4BJ0x46gTrOjKNbCnGhZW6HfmKCenK92/T9lIMyvaBzribnayHxBRpMjQlZuidwg
         hL4g==
X-Gm-Message-State: APjAAAXLryCYPlj9sJDONLYJrVRj4HNiR51s4xoDTVSCRvW2NoVMv+/u
	362Rij38tG2/MTEfBenhD7Y=
X-Google-Smtp-Source: APXvYqwS3DgaAm4+vLvXAZ9Zeo7tempzemZdQsTbxW4zTwntlSTwtllhm6sBWPklubMkYQGCbwWwmA==
X-Received: by 2002:a17:902:bc41:: with SMTP id t1mr8526868plz.171.1565723683044;
        Tue, 13 Aug 2019 12:14:43 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id i126sm130247051pfb.32.2019.08.13.12.14.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 12:14:42 -0700 (PDT)
Date: Wed, 14 Aug 2019 00:44:35 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	khalid.aziz@oracle.com
Subject: [Question-kvm] Can hva_to_pfn_fast be executed in interrupt context?
Message-ID: <20190813191435.GB10228@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000036, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I was looking at the function hva_to_pfn_fast(in virt/kvm/kvm_main) which is 
executed in an atomic context(even in non-atomic context, since
hva_to_pfn_fast is much faster than hva_to_pfn_slow).

My question is can this be executed in an interrupt context? 

The motivation for this question is that in an interrupt context, we cannot
assume "current" to be the task_struct of the process of interest.
__get_user_pages_fast assume current->mm when walking the process page
tables. 

So if this function hva_to_pfn_fast can be executed in an
interrupt context, it would not be safe to retrive the pfn with
__get_user_pages_fast. 

Thoughts on this?

Thank you
Bharath


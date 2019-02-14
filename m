Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 818B0C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 23:49:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D02721B68
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 23:49:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tycho-ws.20150623.gappssmtp.com header.i=@tycho-ws.20150623.gappssmtp.com header.b="hvEkx0sD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D02721B68
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.ws
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B700F8E0003; Thu, 14 Feb 2019 18:49:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACE9A8E0001; Thu, 14 Feb 2019 18:49:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 999C88E0003; Thu, 14 Feb 2019 18:49:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0D18E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:49:50 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id m34so7390695qtb.14
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 15:49:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=iysI1wB/0IWb4pCFfVwtSNZMVU6oGg5xTMZgAA4BlqY=;
        b=J8Hr88lA4GXv3vKVqRRxjjiaef4lVQyFAXnaBVx/tBiyTbTGI82Olp3P4v6EKBnhqE
         39QqmgWPON2YInausWvfz4fZUwo5rwF1V9w5sVI61aGBZYaUbP6Hab+AwO1fgQQn2bVl
         xURi36pRMC8PeOcCT6uTfe5MwhE1x0cUO3zcjOPj6vyfAC68nIJQcT8y6dRSHP/6tW84
         44Vgyx3dkV1xT0eaZhvdsjWndgtnktY6nafy4vR3c1pYIqqaRVNjjfmM7WriIfL3kyCR
         t0Quvyobx9bIhp9619K4G5ByzmpnaJwhgmUCrVICW+66HjL4MojflRL+XtBUSMV1CHsy
         8hDg==
X-Gm-Message-State: AHQUAuaJyZYx67XedTgvD7qZSY8U6tdRW9ZDO3/yyCb/d7cNqt6S5ke9
	Ug+FQRvm+ZOkDxZkiK+gKNcDFf7X1gFRdlYCdGFbef2Bg2hkmznMOq+5NEYBJNlrbmsTbAUQiMp
	6lwGx/Pr2OEjAjHKhC6XbFQwU5sju8YgzXNNWDB/24RXQVTdHpuhjcZ09ppJ49ZForLLZjCxf7g
	HcjXf+VXBjh/7jC/pT64umdSCFLGBJsiKmI2SW221Tasl5LcmbylRYDzMXO4Gp6XUigP1RNHU+o
	ZvA2FVgtv1dCAuKWcm5O5Mf+RWVLMorFhCTtftubX8s1RQeSqAzzf8wiq8TCAnQYkCIJBHFDdEx
	8BLyIvJWF1i4tsOS/b6Ifz05z4Nc5yad6O3tLUp5fuKRnfevchY94n6wqsPOGfpdMiv71WVljNk
	e
X-Received: by 2002:ac8:1c4a:: with SMTP id j10mr3612208qtk.37.1550188190195;
        Thu, 14 Feb 2019 15:49:50 -0800 (PST)
X-Received: by 2002:ac8:1c4a:: with SMTP id j10mr3612177qtk.37.1550188189403;
        Thu, 14 Feb 2019 15:49:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550188189; cv=none;
        d=google.com; s=arc-20160816;
        b=pIzMWrUXbZ7fZxiHmXrlvnIQS1hm2hlbP/FOSMRIsgBlHn/IIb78s1mVkEwn6EFSZJ
         dNYMuxF5lNid6EzyCcACuWGb98ZxMYlASN/0f7slBHn3Z9EFqkpxl9KpNvnrBAQNfj2l
         lFlJJPs17/2oAS1My9x09NDUouRQK1cbrzVJg1q/Hs8Zmpq3pI6AbNY0jP0TOyRhdZZ5
         VHNygyJFeQD8at272pOaTzmFQiFeYvEFQuq/4UTKUo8V3cr8R3PoDGhm1OHu02ROQiCa
         P1RdN6DdM66p+1CQzlH3UjDFcGojt6wjpv5Zq2k5JDu8bsYyZy6mLekBMaj4DyxWTebN
         y6Bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=iysI1wB/0IWb4pCFfVwtSNZMVU6oGg5xTMZgAA4BlqY=;
        b=i5DCWgnim1CG/6Lsf/htcjDJLkbPCRLOD7zar5MMt4ZMZ0NTNz668G9QtO5k7sjV7+
         BqZBpUXP3pgy34PnE9xfzwnvI3lsIXXBgbh1assItyTs6XYWIFa86kvlfKwtf+0Agif1
         be5WHuwjbTbbJAdspgS/nitfIm3Mtq7WNuRKve4FtFBLSoGdPia73+y8l95fVNIYri+1
         6HYIWYK6r4Nl3CADLX/Gs9s+WfqD7AwKwxDaFHThIL9JIOYqr57kULt0O5M5todJT/3y
         gUFyi+OMn+3bBFoA33LlLext9K86B1mCVVIOngBhzyQNN4+g/DrGywDnFjDd3gPSwnfi
         Okqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=hvEkx0sD;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l15sor4942895qtr.63.2019.02.14.15.49.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 15:49:49 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=hvEkx0sD;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tycho-ws.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=iysI1wB/0IWb4pCFfVwtSNZMVU6oGg5xTMZgAA4BlqY=;
        b=hvEkx0sDae+vXuPkRrfz6GJpMcmtwOQoFSjorPtzJ7i/ZlZ+N2DS8RHhtUbzd2y8aO
         93zCFM5f7/VQorSYljRscCmvDMT6v89kczMv5nSnCHvFEegerCJ6Xb764Nd59OwMZGh2
         NR0NbloEkvUqHfCWvo4BrQcaPp8/NpqhtjLmAQgxztm5ByUDgCAXzPDq+BlqmiBG8EGV
         ME/1vaG7H5+GvHHBdTqNAFIcuC2Ueippty3sTQasR/b//BeWt+Za8V6wljLiKAfeu1Ua
         8dD/hcP3II2Mhhb9gsYGvTIhagIB+dNDWETUdvkn94BpgBZq/gWHYermiCVlUERwF+Bk
         K6ww==
X-Google-Smtp-Source: AHgI3IZknsyHISGjxlHiQOHLeB8lB0ycvuC7u1AyuZY91RkGx/hANlj0RYTPcWTfc+1rGg/X944lrg==
X-Received: by 2002:ac8:969:: with SMTP id z38mr5363680qth.49.1550188188860;
        Thu, 14 Feb 2019 15:49:48 -0800 (PST)
Received: from cisco ([192.241.255.151])
        by smtp.gmail.com with ESMTPSA id y68sm1965923qkd.49.2019.02.14.15.49.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 15:49:48 -0800 (PST)
Date: Thu, 14 Feb 2019 16:49:43 -0700
From: Tycho Andersen <tycho@tycho.ws>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, jsteckli@amazon.de, ak@linux.intel.com,
	torvalds@linux-foundation.org, liran.alon@oracle.com,
	keescook@google.com, akpm@linux-foundation.org, mhocko@suse.com,
	catalin.marinas@arm.com, will.deacon@arm.com, jmorris@namei.org,
	konrad.wilk@oracle.com,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
	tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
	jcm@redhat.com, boris.ostrovsky@oracle.com,
	kanth.ghatraju@oracle.com, joao.m.martins@oracle.com,
	jmattson@google.com, pradeep.vincent@oracle.com,
	john.haxby@oracle.com, tglx@linutronix.de,
	kirill.shutemov@linux.intel.com, hch@lst.de,
	steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
	dave.hansen@intel.com, peterz@infradead.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	x86@kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v8 07/14] arm64/mm, xpfo: temporarily map dcache
 regions
Message-ID: <20190214234943.GF15694@cisco>
References: <cover.1550088114.git.khalid.aziz@oracle.com>
 <ea50404604bdbe1547601b6ea0af89e3da8886b0.1550088114.git.khalid.aziz@oracle.com>
 <20190214155435.GA15694@cisco>
 <92787149-bb9e-6ee9-6d04-431ec145e9a4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <92787149-bb9e-6ee9-6d04-431ec145e9a4@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 10:29:52AM -0700, Khalid Aziz wrote:
> On a side note, do you mind if I update your address in your
> signed-off-by from tycho@docker.com when I send the next version of this
> series?

Sure that would be great thanks. This e-mail is a good one to use.

Cheers,

Tycho


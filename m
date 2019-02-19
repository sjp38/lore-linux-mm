Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB4FEC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:46:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C7BE2147A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:46:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="gIUi5rxE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C7BE2147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADF878E0003; Tue, 19 Feb 2019 15:46:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8D058E0002; Tue, 19 Feb 2019 15:46:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97CC88E0003; Tue, 19 Feb 2019 15:46:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0FC8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:46:35 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 207so706499qkf.9
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:46:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=CsKzvaB415MlgCLK3GNkAHykh/hgDaRYokNypf4LqRA=;
        b=Kjkh1vHF+DCHT2tfrALF7P6//Z7ZyK5aNc8nHh/CFkmi40sfG4BpvUlv0hotYTCHQ2
         s8rpU+udEeCZY/T0DDVWFi/tTwpG5AwcbrqamjyKedZwKkLYuDH4k63+XfPtvX8XcWYo
         NIQ/PqZtcC2mKLvr7aiiLw7UeBXRrcSY2OZB+dRktwYxNeHUEvqEo4ymhJnRPkGBdoOm
         Du9viMe8UARi39VG20kzUZj1Z74adMSo7VnF7m6ywEzg+/YLmG84BTS77T7WStD9DREt
         llvOISDA3KyZ5D6Pir0vrj7UgkYAfy5EzWYZ2bgPYHmrPsdGyUBzcdflSL0LFd1xRSiC
         76NQ==
X-Gm-Message-State: AHQUAuavvIZ6KmYSOFxTJEN/nTCz7AqgcX5Y6so9/NwTXMGDIAt9hKlf
	7x3xA+mYQAMDdi/h4EaMho/Uwq1rnl01X5s3y2xFhD+WM/OPV1G8De47f8Bel7lSbCMXmLa2DEI
	Tlfegqbsz6EtWOuWrkNGlmP21ljBLFSJUqiVVOEd9HiGBK7/+qkVlEnum0myoIkc=
X-Received: by 2002:ac8:2ce4:: with SMTP id 33mr24451338qtx.6.1550609195228;
        Tue, 19 Feb 2019 12:46:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYfkkpUMZuS0tanRY60TivUZSX/6D/CV6m638dKVmeg+rTPx85x+NgIDZetqtGW/i4Q46cH
X-Received: by 2002:ac8:2ce4:: with SMTP id 33mr24451304qtx.6.1550609194608;
        Tue, 19 Feb 2019 12:46:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550609194; cv=none;
        d=google.com; s=arc-20160816;
        b=I077a0JyheJxinPF5Esgbm8uT3QVKbwXVV0shIdp8KSt2h8FA2QR1hAyFJgj6aW3D8
         Np644kq7HVE+x2L/+VOBe5ANACEs9G/lFewfF74t4JyjGCVVTkaHvHdiqTGNoDZl+2m5
         UaHO2T18EAZ5WzjI5DpDnFqdXVSmubhClzbeSbfMFEyI2NKhc811S+wUtDDEm4+z3UaF
         smVD6XvkLNTX3HJS826i8mj7H19/pbMcTB1rpy6adI/XM8MuamUpu2fDTn1SBk1MVdIL
         VIwrmYe5REJOYE0FFVKwP+KLi2TM2QjB4RY9ySQ6WIZenNJxrF9Um4i14yfukJM4b8+8
         Ft0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=CsKzvaB415MlgCLK3GNkAHykh/hgDaRYokNypf4LqRA=;
        b=q/PPNuXhxNIoYxMPwfH0uOYJL2cnsi605vav/qBibEslTnnhVxpSMGU8zVeuefsDBx
         n4mnOgnoCDFsY9UiSffEVaquz7Mk1wh5PnqIfkV+gMKyK9GVoBY264RXjq/swkgXFs5p
         y/1mqs4g70zvcsHl4PgXlMlefK39GM4Qj9wwptRi1KESZXZz/eJBpMZNC8MY1Wl8yZ8j
         SfoaTdtHYWS/w4gJcKcilaR4y88U5h94g9TS6JRp84hvCjt8JuGz3oP/ML+RqvEQwsPQ
         NxkvGEVSH7ddyuILWwOHQfq4OJAdi5pPOvSJk12iDk6www/ooQI5cBj+oI1Ltbb8cL2m
         6meg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=gIUi5rxE;
       spf=pass (google.com: domain of 0100016907829c4c-7593c8e2-1e01-4be4-8eec-a8aa3de00c18-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=0100016907829c4c-7593c8e2-1e01-4be4-8eec-a8aa3de00c18-000000@amazonses.com
Received: from a9-33.smtp-out.amazonses.com (a9-33.smtp-out.amazonses.com. [54.240.9.33])
        by mx.google.com with ESMTPS id n14si5893032qtb.36.2019.02.19.12.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Feb 2019 12:46:34 -0800 (PST)
Received-SPF: pass (google.com: domain of 0100016907829c4c-7593c8e2-1e01-4be4-8eec-a8aa3de00c18-000000@amazonses.com designates 54.240.9.33 as permitted sender) client-ip=54.240.9.33;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=gIUi5rxE;
       spf=pass (google.com: domain of 0100016907829c4c-7593c8e2-1e01-4be4-8eec-a8aa3de00c18-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=0100016907829c4c-7593c8e2-1e01-4be4-8eec-a8aa3de00c18-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1550609194;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=CsKzvaB415MlgCLK3GNkAHykh/hgDaRYokNypf4LqRA=;
	b=gIUi5rxESdlcZrOlTHgHZoK2Z28q83hYp7wO2oId3iM6wPmILcP54NOSwHvxXPri
	ieiXsUMRFEn3UOez7Tv8o3riuoa8fr2pdbJ0CfPFOhER0wipg7axGHLjFDeJ6hZ5Usj
	wVoxifecljlVz6sSPk+IdFGO5ScJWgXKBuGkH+UQ=
Date: Tue, 19 Feb 2019 20:46:34 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Michal Hocko <mhocko@kernel.org>
cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: Memory management facing a 400Gpbs network link
In-Reply-To: <20190219191325.GS4525@dhcp22.suse.cz>
Message-ID: <0100016907829c4c-7593c8e2-1e01-4be4-8eec-a8aa3de00c18-000000@email.amazonses.com>
References: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com> <20190219122609.GN4525@dhcp22.suse.cz> <01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@email.amazonses.com> <20190219173622.GQ4525@dhcp22.suse.cz>
 <0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@email.amazonses.com> <20190219191325.GS4525@dhcp22.suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.19-54.240.9.33
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2019, Michal Hocko wrote:

> On Tue 19-02-19 18:21:29, Cristopher Lameter wrote:
> [...]
> > I can make this more concrete by listing some of the approaches that I am
> > seeing?
>
> Yes, please. We should have a more specific topic otherwise I am not
> sure a very vague discussion would be any useful.

I dont like the existing approaches but I can present them?


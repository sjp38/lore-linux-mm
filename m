Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3ECC8C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:44:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F01062067D
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:44:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="uHWz7Lzg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F01062067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EDC56B0003; Mon, 12 Aug 2019 12:44:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79E1A6B0005; Mon, 12 Aug 2019 12:44:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B3F36B0006; Mon, 12 Aug 2019 12:44:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0147.hostedemail.com [216.40.44.147])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3A26B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:44:24 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id DB1625003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:44:23 +0000 (UTC)
X-FDA: 75814348806.09.robin34_263188a3f0b4a
X-HE-Tag: robin34_263188a3f0b4a
X-Filterd-Recvd-Size: 3621
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:44:22 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id c34so21240145otb.7
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 09:44:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yq4g4ecRC6yyVSOBidSNfdDYV3DpcZPTt6IYgshPZOs=;
        b=uHWz7Lzg7LqLmFXUBQc2JywoOVW9IVEsmh/TkjzxUM6AHyWLM+LzIuqj6recJBuUbU
         BlxxBqFXSRUx0jTdx+KNyI86wiK3Iz8az1t7zFdzRtcrb0Mfr/PXMprq0ZLs8F0DxoRN
         DkcPiw+zyhzUXUz+FtAPm/4/WyrwQXD9XD4QwGsy6LmWel4C1WhSZeDOtD68zyZLiGLq
         xZqkGOmWDL4N8a0Se2lbPo21tdJQ8nNJ4BibKjgNH4nObSnQaKEoWII2GDxM2aINo3/m
         yZPtOY+BjgG55qLTj0lywtYipSVvEZ1acBSUB3GYVeoFySuiMbGXNGuPdNyavQ/khDyj
         rAcQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=yq4g4ecRC6yyVSOBidSNfdDYV3DpcZPTt6IYgshPZOs=;
        b=lM8NXtSPkvEWGwvf3882EaWT563QDdsKLRzFTlH7Wj3a1GaTMKXPP/zB1KcGt6YB5D
         tYFT3cL4yl7zJp5bk+SrYsOriDhXimLJ74HlceXvskUaBkdPK98zj5T7/guiMXxh1XiD
         xKjCT2k3TN3a1TZkSHu4bKnqP24cmNzrMuLk7J40H1c7Gbl3fu5pBHH0/eF4iAGmu6CQ
         6E4Gk6ZeZcZLQNxjkniUmU1lxjZLw5y7tM71VdqjOCXkcGOdE+mqZFCPgP1csBIsuGHh
         EHl+mZ+ujXKwqkgetZ7r5nWtqhdI9E4JtkQby+rK1OVevrzUdly8MstuBDSk10dhtGez
         YvuA==
X-Gm-Message-State: APjAAAXKtjVRNRlOFkJwaUbujDz310Zh0SGtonHYMyX7CjJJxKT5r6mZ
	efj3yLmuvgoXjcQJcHSMojS5Jo5L2RrUpQ6+vxoF4A==
X-Google-Smtp-Source: APXvYqxIc6P5BbOlspBIEJm2S3PD4YurhGQFQZsVfY1Gaxt4ekPGBxAkn2c7Af6apTI665emPRcRSGFJ1tiXWrZdjIE=
X-Received: by 2002:a9d:5f13:: with SMTP id f19mr22476928oti.207.1565628261713;
 Mon, 12 Aug 2019 09:44:21 -0700 (PDT)
MIME-Version: 1.0
References: <156530042781.2068700.8733813683117819799.stgit@dwillia2-desk3.amr.corp.intel.com>
 <x49blwuidqn.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49blwuidqn.fsf@segfault.boston.devel.redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 12 Aug 2019 09:44:10 -0700
Message-ID: <CAPcyv4jZWbBUrig3wnE+VGptMEv3fHeRJbRhmMncQwkjLUbvxg@mail.gmail.com>
Subject: Re: [PATCH] mm/memremap: Fix reuse of pgmap instances with internal references
To: Jeff Moyer <jmoyer@redhat.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	Jason Gunthorpe <jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Christoph Hellwig <hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 8:51 AM Jeff Moyer <jmoyer@redhat.com> wrote:
>
> Dan Williams <dan.j.williams@intel.com> writes:
>
> > Currently, attempts to shutdown and re-enable a device-dax instance
> > trigger:
>
> What does "shutdown and re-enable" translate to?  If I disable and
> re-enable a device-dax namespace, I don't see this behavior.

I was not seeing this either until I made sure I was in 'bus" device model mode.

# cat /etc/modprobe.d/daxctl.conf
blacklist dax_pmem_compat
alias nd:t7* dax_pmem

# make TESTS="daxctl-devices.sh" check -j 40 2>out

# dmesg | grep WARN.*devm
[  225.588651] WARNING: CPU: 10 PID: 9103 at mm/memremap.c:211
devm_memremap_pages+0x234/0x850
[  225.679828] WARNING: CPU: 10 PID: 9103 at mm/memremap.c:211
devm_memremap_pages+0x234/0x850


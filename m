Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D812EC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:35:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95B6720811
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:35:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="2R9S32R3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95B6720811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CBC48E0007; Mon, 28 Jan 2019 11:35:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 054B08E0001; Mon, 28 Jan 2019 11:35:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E379A8E0007; Mon, 28 Jan 2019 11:35:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id B4E8E8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:35:07 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id r82so9353277oie.14
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:35:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3RfSfUYfpAZphq/vcCmv0IEDUe5SxwKKRVSXT2VCPcU=;
        b=fqXCU164BfgrbyDOA7w5gsjJBsoScFmQN4jdPM/rb07ALz+1EFAO3hk6wzOzHhTKHM
         q6owLSO+ebFnPi2x2pNhvk04gWeHPrOse85hjr/XB4vAeSI8ze6A7RvvFwY5kHK/5L8q
         KG1ypZcOh1ZXKtGv243GkQ7kIsEc/Ho39CK/+S8y/2ELjQnupJ7vP+6xC5pDhP01/znM
         eDI+iVvj90I38iA2ExZX8T4jiSmrAj5CYX9EDXqEpfr4f48JppsRC5LgNoKH0oNAbesl
         ixNVVNi70icti2SPpX8GPvfzKUFb0lySP1YVdbavE66f4FXGl9GrKFj2NT3wz0tjRLMb
         SDQw==
X-Gm-Message-State: AJcUukcsMXfZkEpkjMymdi/1f7ff8BZqQN1Dg7TlrDSX+GQ4etzvVVQw
	/4i6S4iU+fWgBLJe9qKgqWzCkOF33Lyex4/L4zoCJmt/EYCnxKTJtuGeJySS5nKsIT96DEglrMD
	S+EZh/fuGmHjkNwbxnp7q0ZreN548e7ejuKZhEikmlNWT2nVkt2sDQ8GhXVsh9ljT+cLXOnVY+z
	sKL9kyymMkWKIRSiMDpzNJooOGbS3Ks/SMH0RO/YUhfTEYjpH8LFComyJ7EZdHib8hZ0+hQJ5id
	okiU1zNi0zC39unt4pN0Fkcr4Cqr6UjJrGLyFQBrCLC90waIRrI50AdhqCyjyIOvuyzqQoP0Fxx
	LkUkCUunMP7a2rusuoYYpEJy4ErMtbQs79dz5KraMMnUdeF4MLBvVmiovbqkcRwJDtQx5WVS66d
	o
X-Received: by 2002:a9d:630f:: with SMTP id q15mr16074643otk.187.1548693307321;
        Mon, 28 Jan 2019 08:35:07 -0800 (PST)
X-Received: by 2002:a9d:630f:: with SMTP id q15mr16074618otk.187.1548693306541;
        Mon, 28 Jan 2019 08:35:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548693306; cv=none;
        d=google.com; s=arc-20160816;
        b=ZUVwkD7C4jyrGVLyG5xk9wd3MT7HPb7Qp3iEXAGEiT2Fgm2kDYF/hYX25JPiqTy9BZ
         qwrNOEvUzx2kGtrOLzFqo84Z5bOF/a9vhMrM+x0HJGF/xrhoxq5iaowdseN113IC6qRJ
         wpQOOVU4t+bIIZKJgcIppuJmgj89ngdl6l126pdVV03IlLTKKtdxN8oVGGHf1D2Smqxh
         r7iLEfOJmLdWBC/O2HjH1kQGN4ey7107GpEbRgLFf1i528VRcJJLqxuUKiEUylCum6gp
         YPh1Pfv1D9jVsUPsD+JiKSqZbiTdIUEWJVijDurlYUVEzyeACWxHeB7ThIb5IWunT9Gd
         w2AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3RfSfUYfpAZphq/vcCmv0IEDUe5SxwKKRVSXT2VCPcU=;
        b=PbkVS4jJEOdznccplC/MQx52bEiEGdQgUkI15UjOqRA+TQ8VQoAyc5hih39bFGpka5
         Cot/WxYs9YnAT3TCIw2ZCP/WsPBFrqVQLBGzHOWDvk6QkNVoSFRpug2ys6sFwc5wh5Wq
         xYxxO4l+lGxPkdrT38Xi+JUXkEuGekVKdfvc51Z6jtjHQdfKxcJKv2kpJVsCdIZ85Zin
         dh5RH2aEsOauvZUEEvCRrxOithbBmr2dqB/x+vjzPWzG3L0CdjE9d4XHTQDvoNbT0yos
         vzGT5H88Kq8lg3QgvrmAqbFnn0olbhRxBFDoLNH3+S32T0+h0UJTT2tqPeFqO0nej7SP
         IPvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=2R9S32R3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t69sor6263336oie.88.2019.01.28.08.35.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 08:35:06 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=2R9S32R3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3RfSfUYfpAZphq/vcCmv0IEDUe5SxwKKRVSXT2VCPcU=;
        b=2R9S32R3QbZIbFSXmkascFMRRVMAOiMqJ3qvr07hqBS1ju4LNBiYd8iN0aJlFJ/JOd
         ElwAmIWmUZVOJZh97bQmAQNPXvf4VeX/+ilxGHTi0QIP+0rQncKNqMKRYlz+MSD4MPWe
         7SOir2tSv8csXy26UxMYxsv2CVHTjd6wJ++zLlWA+0KqzFCGxEyu/6nu+5t98s1PMWuH
         5zQibZ8M9eYLnxd+kpWMF/5/REPgfD5P0t+Rn9anI3+Izb4dePLt3HH+s6g9ZII/B1ph
         ENHZXTvgfY1CqvGoI4ipoCYITGRfAZREThglH4ckIwDdQ19VSdjSvyi+R7cgPuXSRaKf
         txJw==
X-Google-Smtp-Source: AHgI3IbgJFlk8tJrI0mFbIeJrfjOlDEgz5j1qQlr0yPgG1LT8xVUjEcpah7jVEe/+JNiBZ1fjnUfa6ZOjZFL+/OYxKM=
X-Received: by 2002:aca:b804:: with SMTP id i4mr6360983oif.280.1548693306097;
 Mon, 28 Jan 2019 08:35:06 -0800 (PST)
MIME-Version: 1.0
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231448.E102D18E@viggo.jf.intel.com>
 <0852310e-41dc-dc96-2da5-11350f5adce6@oracle.com> <CAPcyv4hjJhUQpMy1CVJZur0Ssr7Cr2fkcD50L5gzx6v_KY14vg@mail.gmail.com>
 <5A90DA2E42F8AE43BC4A093BF067884825733A5B@SHSMSX104.ccr.corp.intel.com>
 <CAPcyv4ikXD8rJAmV6tGNiq56m_ZXPZNrYkTwOSUJ7D1O_M5s=w@mail.gmail.com>
 <b7d45d83a314955e7dff25401dfc0d4f4247cfcd.camel@intel.com>
 <dc7d8190-2c94-9bdb-fb5b-a80a3fb55822@oracle.com> <CAPcyv4hEyG-1hC=20M7YGFG-BF7yvNcG7EkLurAfysHHB2yXBA@mail.gmail.com>
 <20190128092549.GF18811@dhcp22.suse.cz>
In-Reply-To: <20190128092549.GF18811@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 28 Jan 2019 08:34:56 -0800
Message-ID:
 <CAPcyv4j2vmWXQO0QoBU5-yXBJBaEuDrPJ0t1tWkftCbwb4rnWA@mail.gmail.com>
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal RAM
To: Michal Hocko <mhocko@kernel.org>
Cc: Jane Chu <jane.chu@oracle.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, 
	"Du, Fan" <fan.du@intel.com>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "tiwai@suse.de" <tiwai@suse.de>, 
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jglisse@redhat.com" <jglisse@redhat.com>, 
	"zwisler@kernel.org" <zwisler@kernel.org>, 
	"baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>, 
	"thomas.lendacky@amd.com" <thomas.lendacky@amd.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, 
	"Huang, Ying" <ying.huang@intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128163456.FgKxQHC6gQXkzhFUMKLkufdIG-NVXXHY4MTlEXpJyKg@z>

On Mon, Jan 28, 2019 at 1:26 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 25-01-19 11:15:08, Dan Williams wrote:
> [...]
> > However, we should consider this along with the userspace enabling to
> > control which device-dax instances are set aside for hotplug. It would
> > make sense to have a "clear errors before hotplug" configuration
> > option.
>
> I am not sure I understand. Do you mean to clear HWPoison when the
> memory is hotadded (add_pages) or onlined (resp. move_pfn_range_to_zone)?

Before the memory is hot-added via the kmem driver it shows up as an
independent persistent memory namespace. A namespace can be configured
as a block device and errors cleared by writing to the given "bad
block". Once all media errors are cleared the namespace can be
assigned as volatile memory to the core-kernel mm. The memory range
starts as a namespace each boot and must be hotplugged via startup
scripts, those scripts can be made to handle the bad block pruning.


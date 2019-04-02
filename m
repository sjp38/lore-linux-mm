Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADC9AC10F0B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:17:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54BC5204EC
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:17:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HqHi3KXr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54BC5204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C381C6B0005; Tue,  2 Apr 2019 12:17:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE6F16B000D; Tue,  2 Apr 2019 12:17:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAF996B0010; Tue,  2 Apr 2019 12:17:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 720A36B0005
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 12:17:21 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j1so10247468pll.13
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 09:17:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=JbfDVSihwTx21ysjcpNCAdgycCvIFZGZ/Q4z4v790s0=;
        b=VvHpJH5/toSMm/sCHFMnNw7ZXUAiAuBrCZZmMS9JCm8AgFath5S7vzCeOP/cvnK1b6
         Sdo2THmbuIB+KHQ22Qk5OQni7N4FQSPBwlHudyhHgyR1e6VeQDpnR3HXozLcwaEJYKB3
         OKIojyRZW92uYVtFWqk+rozK2Tv2PqoqBPjMzDj8gK1WuIHEcNk/uo+90qI+pPIlHjMO
         824nGJBUsMyUtJuZLZADMzzgNmbcReWWVRB275xqkgEFyRZF82Nm2pGoB7HrK+P3Br4F
         pJKM5HFtkB2KBllElcC07dTol5NQbblOFVHi06cdgEextP9uPFU3Hbm1h7/R82tFZFIZ
         kqsA==
X-Gm-Message-State: APjAAAVU11cA0mewrv7y0Niva2FKxcFAC7Qw7V1AXZCAQyyWjPxC/6/b
	6QPs3a8cCRTAUlWUe2pVnnX5LmycFhpJ0apc2SjfVY0A8WbKcmnHc0Wq5wB72HMa0pcEmLENaJt
	z2NAYEe7HCfq1/FCrIe/SYTaTEHglwONOhbseySeuGBbJuD+x2wJy8T6yRxjLLjVAsg==
X-Received: by 2002:a65:5c4b:: with SMTP id v11mr66615114pgr.411.1554221840916;
        Tue, 02 Apr 2019 09:17:20 -0700 (PDT)
X-Received: by 2002:a65:5c4b:: with SMTP id v11mr66615053pgr.411.1554221840259;
        Tue, 02 Apr 2019 09:17:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554221840; cv=none;
        d=google.com; s=arc-20160816;
        b=V0kiv33UKkU8Sd5q7vmSYyf1G+5Q2QpaBEsP8TG7398Bsq/cTqi0Y00ywI6FPass39
         7EsL29hU1bWV8quaFtPbw6KAs/kF5RjJ3UnVP0fr2k6E9YwViiU8jUeEnW9OKcYdkgcg
         644s7P5t0hkQkA77gryAgHw1Za5VW/nJprZ8SqCg8FU6sLK8kv/TJRC6xWHCBERvHgid
         cVtfp2Ab/0HCKhResHXKPmex0dfU1AfzrPVPYfKKaddNjpzSsdg14ahx0OOEZ6CSSHQd
         46fBchAg8lUSLF9nB2FWvwnubnK0dslVSqu+WOmEVdkHW3vCMApkoBCIppiBifNvcmPV
         dvwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=JbfDVSihwTx21ysjcpNCAdgycCvIFZGZ/Q4z4v790s0=;
        b=TwVJ7AGe2aoSAltM6MhT9pJ+zaBJ3G1C+h7l3BFvOQYK3Z7pCjvT2AQj2butImcPkI
         6CvsFTaNJRsRJXHr3z7DxAFRtYm0Ve8AhaOzjBM76ZIDn9+QJuJ4MPi6pcBYx9v57QdI
         XyXbysEIkve+ZYpjfQ9QsioTAu4C8/WTmTwz4ebpyKW5IHDmM4/kPir5o/w279GRkEkZ
         7hVu375CvGpnaOGE0q4M6XBsJQmJN81uvT0fskvmalrOgqztYEF4ANTj/lWPCsccl9rW
         I9F4IVt/ob7DiIKOCx+00agVKhzfwVMSNzdJZik3avVQQzedMZDGu8Br2EIIK6D6+nJ2
         V44Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HqHi3KXr;
       spf=pass (google.com: domain of nikitas.angelinas@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nikitas.angelinas@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y196sor13781617pfb.16.2019.04.02.09.17.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 09:17:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of nikitas.angelinas@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HqHi3KXr;
       spf=pass (google.com: domain of nikitas.angelinas@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nikitas.angelinas@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=JbfDVSihwTx21ysjcpNCAdgycCvIFZGZ/Q4z4v790s0=;
        b=HqHi3KXr+FXHd4AqTz1ou1EFpoK3fZUF2eztfS2BBqq/LlDPQ48vdtCQTwYGN43QiL
         H5zNFG+pjs+3KnACZcR4Mr4/yGKxX5yqlHViGHd7eG6wvy74YS8uVi6RtpRVJjoTS69P
         VmAZI4o/dQAn95e/vqqCZKj6C9qiTQ/Y0xdryj+Ji0lUpM0zfTs+SxmG8jl21kKI6PU3
         e4WPzkQoypjPEA+o34ASEEcziOaQBKM9FcITcDdVdo997nHiPQ8jMjVqxq3rNYzXXvs/
         2vlsPRzXeDy8nXfQhtzfd8f96hpbvL+uR1Gm77WsRLPtjMQFnKd6H1d9+uDkiaWoMj+7
         cWrg==
X-Google-Smtp-Source: APXvYqzBPmWUn8xkWl5jCa/CxzGFeOEfjylG8P8xS/YVegMfkHlqp/y8C6vW1V1oLe4qgab0OnSsbw==
X-Received: by 2002:a62:5ec2:: with SMTP id s185mr3423780pfb.16.1554221839526;
        Tue, 02 Apr 2019 09:17:19 -0700 (PDT)
Received: from vostro (173-228-88-115.dsl.dynamic.fusionbroadband.com. [173.228.88.115])
        by smtp.gmail.com with ESMTPSA id o67sm16832118pga.55.2019.04.02.09.17.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 09:17:18 -0700 (PDT)
Date: Tue, 2 Apr 2019 09:17:10 -0700
From: Nikitas Angelinas <nikitas.angelinas@gmail.com>
To: Mukesh Ojha <mojha@codeaurora.org>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: kernel test robot <lkp@intel.com>,
	Alexey Dobriyan <adobriyan@gmail.com>, LKP <lkp@01.org>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: b050de0f98 ("fs/binfmt_elf.c: free PT_INTERP filename ASAP"):
 BUG: KASAN: null-ptr-deref in allow_write_access
Message-ID: <20190402161710.GA4152@vostro>
References: <5ca377a6.5zcN4o4WezY4tfcr%lkp@intel.com>
 <86f16af9-961f-5057-6596-c95c0316f7da@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86f16af9-961f-5057-6596-c95c0316f7da@codeaurora.org>
User-Agent: Mutt/1.7.0 (2016-08-17)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 08:53:42PM +0530, Mukesh Ojha wrote:
> I think, this may fix the problem.
> 
> https://patchwork.kernel.org/patch/10878501/
> 
> 
> Thanks,
> Mukesh
> 
> On 4/2/2019 8:24 PM, kernel test robot wrote:
> > Greetings,
> > 
> > 0day kernel testing robot got the below dmesg and the first bad commit is
> > 
> > https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > 
> > commit b050de0f986606011986698de504c0dbc12c40dc
> > Author:     Alexey Dobriyan <adobriyan@gmail.com>
> > AuthorDate: Fri Mar 29 10:02:05 2019 +1100
> > Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
> > CommitDate: Sat Mar 30 16:09:51 2019 +1100
> > 
> >      fs/binfmt_elf.c: free PT_INTERP filename ASAP
> >      There is no reason for PT_INTERP filename to linger till the end of
> >      the whole loading process.
> >      Link: http://lkml.kernel.org/r/20190314204953.GD18143@avx2
> >      Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> >      Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> >      Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >      Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> > 
> > 46238614d8  fs/binfmt_elf.c: make scope of "pos" variable smaller
> > b050de0f98  fs/binfmt_elf.c: free PT_INTERP filename ASAP
> > 05d08e2995  Add linux-next specific files for 20190402
<snip>
> > 
> > ---
> > 0-DAY kernel test infrastructure                Open Source Technology Center
> > https://lists.01.org/pipermail/lkp                          Intel Corporation
> 

Hi,

Yes, it should.

Andrew seems to have added the patch to the -mm tree.


P.S. Apologies to individual recipients for the double-posting. I am resending
this as the previous mail was rejected from linux-kernel and linux-fsdevel due
to HTML content.



Cheers,
Nikitas


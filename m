Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC0FEC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 18:44:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 567C320835
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 18:44:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="fxLM/HTo";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="HbbSoRZ5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 567C320835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C47618E0003; Wed, 13 Feb 2019 13:44:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF6BD8E0001; Wed, 13 Feb 2019 13:44:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A98128E0003; Wed, 13 Feb 2019 13:44:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 652F48E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:44:39 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id i11so2288357pgb.8
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 10:44:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:dmarc-filter
         :subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=PHzAU4HUNBCq3y3wdeMIQBv6wIv+y+vWTm3oWd0aw0E=;
        b=tmG0E4S/WO0W+gGRjCxDUxR/ypbPzpuHdk+YSl5Ujd2sgplc3JH59SRUUJPnxNvZJf
         xQHOkCr9oJl/ttkijkkRARF3ysdUbdMlPH4bhdOmBuat1tnPrDAivSDZDJXG1ECT3Da2
         2jyeHMKfV+HALi8jpvWqh0m5q668ihUeBkqlaWT5UvyVKB5WB46irYQeNXDPDTI/0hB5
         BTZaoIulopPReDv0HHpiCVj3l4uFwqDm1kprz/7USAtymiLUshmSHd5Ddce3l4DzYjG5
         CfpHo58R81hrRQ8Kfv5K5yCYz2TyukjDekt1x9RldNgI9WPhtwtUtypo6lA5frmggf1/
         tnog==
X-Gm-Message-State: AHQUAuYZbee14TKsLqf+LBYsVNTepDTdFAYPgTzZOUrZRYVWQDVBL8s9
	6YRWhMWydAxHZPhCtBCem+05nlXLVbiu6pw7aMzDwAVc+aTPI27Y+1eOtzt27mHf7S6ngFUSt8x
	TN7mOKm+K5Qhn7IF89ANEgQ9WlR2MihiYzjby36xFhLxkjWY16LtJPcEgDA0OCyIYEg==
X-Received: by 2002:a63:2705:: with SMTP id n5mr1708624pgn.429.1550083478989;
        Wed, 13 Feb 2019 10:44:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYf/LvC4M6xGt1Ihjwa2PWKlljH47o1yX3R8xtNno3WjDjNvPy6e2q4znsce0N1kh2cyjvc
X-Received: by 2002:a63:2705:: with SMTP id n5mr1708586pgn.429.1550083478177;
        Wed, 13 Feb 2019 10:44:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550083478; cv=none;
        d=google.com; s=arc-20160816;
        b=TRNQ4GEj8vhVIQOAL76W4U4LCFRnTTwMSUbkAoUnk76eJDk6EWECBsEbp4X3FeNY8Q
         CFVPzGHRI1ze79XOh0HJ+RfzN2RFPhZQivywLPFEhl4HdQYWDPNfsi4f86iCBA/AX7dz
         dy9riV0L9Z9iYlFAmg833/l3Z/yrPtRiV+XBxkL6ubHsf37d9SOmbY0HWsem8hB//JRp
         v1VGb9h7tFueJQ3iMdL2Rtt/LY8h1sYwZM9ICrph41csWLje6k8AmyJg3s+bB90YNfvT
         MvJPIcaVtUZcHBg1eKdbS4Dlka3e3uktapff6JjF8qR4blJXNg9Kthlctl9r2QkUEohd
         FdhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dmarc-filter:dkim-signature:dkim-signature;
        bh=PHzAU4HUNBCq3y3wdeMIQBv6wIv+y+vWTm3oWd0aw0E=;
        b=U8gGbMHk1A9zfK9r/p4/JJIQ2d6Ju7LybQ6eacXyo51zl1tehqdX9towGthc1wq6Nx
         49ePoer12TBBncjto7kM7gjDS+gHgKcBGw5tG+2FzbtmecOVekg+h7/TRV3WE4w/WgvT
         078EGs6KSerZVwWQh77UZXGqncgr+iy3VSDH8BejUU6q72oGjohzsQNO+LaCxCDy4UTA
         YSFt6/cz6OkwyakQPCB/joLICRX927Dj8QKpYTeyt7D4f8TRENNjrOrHXki4Akyyla2U
         /RV9vWUZg2FpPL59EGBUasKuZWfg8lQv1fqh+kivmtOCfjB9lgRaCpL1Zi0JGrd8HoWh
         /qcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b="fxLM/HTo";
       dkim=pass header.i=@codeaurora.org header.s=default header.b=HbbSoRZ5;
       spf=pass (google.com: domain of saiprakash.ranjan@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=saiprakash.ranjan@codeaurora.org
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id r12si39587pgf.22.2019.02.13.10.44.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 10:44:38 -0800 (PST)
Received-SPF: pass (google.com: domain of saiprakash.ranjan@codeaurora.org designates 198.145.29.96 as permitted sender) client-ip=198.145.29.96;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b="fxLM/HTo";
       dkim=pass header.i=@codeaurora.org header.s=default header.b=HbbSoRZ5;
       spf=pass (google.com: domain of saiprakash.ranjan@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=saiprakash.ranjan@codeaurora.org
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id 44CA5608CE; Wed, 13 Feb 2019 18:44:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1550083477;
	bh=F87YOsPP9BTuLaqkEIDa5weDH2iiqGmOdN1YadkeJNE=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=fxLM/HTogcZbQ1gUCOtHsytxjeMCzFU3pejbivwr4SX7ISB3zPfuMSNlJQWhI35aD
	 kLozx9XeeceQUvQTfr7/0EF+4rjUWNOvwPgT0ciEJd3z3/8kN70IK6dBdNMDvPInIq
	 CplU6vLtb3fGe2AEFE+MKFtt6+TIFkt0Ub+s2zTI=
Received: from [192.168.1.101] (unknown [157.45.221.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: saiprakash.ranjan@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id D09CE60C3D;
	Wed, 13 Feb 2019 18:44:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1550083476;
	bh=F87YOsPP9BTuLaqkEIDa5weDH2iiqGmOdN1YadkeJNE=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=HbbSoRZ5E3D57TggqaplIL+7LSjb29zLnCED9DNxSum0WaWnR7UFps049LRVuzIxO
	 0/g57YacSkEb3vZzDguBsT2lVOq2Q1X2snOSqR/VPc1HoLb18wV+R4nhDVxcx3czm5
	 XRF6NSeHQpW19w4XS0XWYsWnqge6xdSegmMHkJxM=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org D09CE60C3D
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=saiprakash.ranjan@codeaurora.org
Subject: Re: BUG: sleeping function called from invalid context at
 kernel/locking/rwsem.c:65
To: Pintu Agarwal <pintu.ping@gmail.com>
Cc: open list <linux-kernel@vger.kernel.org>,
 linux-arm-kernel@lists.infradead.org, linux-rt-users@vger.kernel.org,
 linux-mm@kvack.org, Jorge Ramirez <jorge.ramirez-ortiz@linaro.org>,
 "Xenomai@xenomai.org" <xenomai@xenomai.org>
References: <CAOuPNLgaDJm27nECxq1jtny=+ixt=GPf2C7zyDsVgbsLvtDarA@mail.gmail.com>
 <6183c865-2e90-5fb9-9e10-1339ae491b71@codeaurora.org>
 <CAOuPNLgUvECE6XBjszFggY3efmEBKywzKNWupjfQ2svsCMqd7w@mail.gmail.com>
From: Sai Prakash Ranjan <saiprakash.ranjan@codeaurora.org>
Message-ID: <2c91af7d-4580-cedc-70ea-d38c2587c7bf@codeaurora.org>
Date: Thu, 14 Feb 2019 00:14:28 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CAOuPNLgUvECE6XBjszFggY3efmEBKywzKNWupjfQ2svsCMqd7w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 2/13/2019 8:10 PM, Pintu Agarwal wrote:
> OK thanks for your suggestions. sdm845-perf_defconfig did not work for
> me. The target did not boot.

Perf defconfig works fine. You need to enable serial console with below
config added to perf defconfig.

CONFIG_SERIAL_MSM_GENI_CONSOLE=y

> However, disabling CONFIG_PANIC_ON_SCHED_BUG works, and I got a root
> shell at least.

> 
> But this seems to be a work around.
> I still get a back trace in kernel logs from many different places.
> So, it looks like there is some code in qualcomm specific drivers that
> is calling a sleeping method from invalid context.
> How to find that...
> If this fix is already available in latest version, please let me know.
> 

Seems like interrupts are disabled when down_write_killable() is called.
It's not the drivers that is calling the sleeping method which can  be
seen from the log.

[   22.140224] [<ffffff88b8ce65a8>] ___might_sleep+0x140/0x188
[   22.145862] [<ffffff88b8ce6648>] __might_sleep+0x58/0x90         <---
[   22.151249] [<ffffff88b9d43f84>] down_write_killable+0x2c/0x80   <---
[   22.157155] [<ffffff88b8e53cd8>] setup_arg_pages+0xb8/0x208      <---
[   22.162792] [<ffffff88b8eb7534>] load_elf_binary+0x434/0x1298
[   22.168600] [<ffffff88b8e55674>] search_binary_handler+0xac/0x1f0
[   22.174763] [<ffffff88b8e560ec>]
do_execveat_common.isra.15+0x504/0x6c8
[   22.181452] [<ffffff88b8e562f4>] do_execve+0x44/0x58
[   22.186481] [<ffffff88b8c84030>] run_init_process+0x38/0x48      <---
[   22.192122] [<ffffff88b9d3db1c>] kernel_init+0x8c/0x108
[   22.197411] [<ffffff88b8c83f00>] ret_from_fork+0x10/0x50

 >
 > This at least proves that there is no issue in core ipipe patches, and
 > I can proceed.

I doubt the *IPIPE patches*. You said you removed the configs, but all
code are not under IPIPE configs and as I see there are lots of
changes to interrupt code in general with ipipe.

So to actually confirm whether the issue is with qcom drivers or ipipe,
please *remove ipipe patches (not just configs)* and boot.
Also paste the full dmesg logs for these 2 cases(with and without
ipipe).

Thanks,
Sai

-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a member
of Code Aurora Forum, hosted by The Linux Foundation


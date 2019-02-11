Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=DATE_IN_PAST_24_48,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B385CC4151A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:22:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D931222CC
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:22:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D931222CC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 175038E0002; Tue, 12 Feb 2019 13:22:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1262B8E0001; Tue, 12 Feb 2019 13:22:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2F308E0002; Tue, 12 Feb 2019 13:22:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B46678E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:22:40 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id h15so3020756pfj.22
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:22:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=jImWSWSzvk0BYFosk8nq2RqkOLgHcmKoR4Zy5d6aQj4=;
        b=LnxoCLpN3DFNJG4e8LCux7KPUYLCEL+xaF7J+jS/nwxADpiSUn1XZTZDlPLwhzbzUq
         WWQ8yuTfrgdyylVDUdOvWAnC+slpQ2FvENtGI4K/6azkiqJx/QFB4cl8zn9lsz4pnb5o
         /ju4p+phNmKXfpWbq+DVQQxXmpjMLkZMQ6A3i0JH5xwCbDOjv4YUSeNieAJaqpxX2vdY
         n5mE/0dOcf1oo4RHIQanpm4TXjv5I8KpN7k3rLUlUYIaG3Gg0CVp2PCyQT4SGI24WdZQ
         SXnJ5pCX0XAiCRSWksViI62Gqy+TrLi8a+QOdJcUmFJMoC9C5PMwBiMDeWhbsTLjj5uf
         EzJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYLsJ85bmh9W614F9cUzPR7Z+jTTaWSyjAUHTeaC+WF6urOW5Xq
	0f4s05SxukcD7ZjEgOWfAfIFQ8wBRkdb+oIpyHtCs5cmNMIdcoGUPTkgsdo9KB6L8sRGMcuc47Z
	CtV8Uey+SHItldwhN9BAuIJsSQrzC2jkh+iY5JwCBkTKTAvVdRxhuT4N7H43vPmA1UA==
X-Received: by 2002:a17:902:7588:: with SMTP id j8mr360877pll.22.1549995760367;
        Tue, 12 Feb 2019 10:22:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaxnPv9JnhkqBx15aNxIPyBcjXNAPAWOflg6JYcBkAG73+sB96+1QJ6YEZT2r3m92DLrR9O
X-Received: by 2002:a17:902:7588:: with SMTP id j8mr360832pll.22.1549995759719;
        Tue, 12 Feb 2019 10:22:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549995759; cv=none;
        d=google.com; s=arc-20160816;
        b=1I25MCJazEZCmOSsZ7FpTmZ+PMhfI+Y6hHcegbZ201wXmGj4DVt0KOv5ajTnBAvxDt
         XR4/IK8T77z2saXNpRUXKcvHDdeCBHK3OpjG74Qn3O8LQGjYu9jz6Drnq6QE2nQb9pcL
         xwB+jSUDivt553mR7RUCr0Q1M9cLbdFJdVnGfLoGu9dXrqMuLxh1dvslXUfo3ZNZhe/B
         Mr5uCS8JsSyKwzyReO3bwNVEdMTdhu6jCV0dNqbJHdLpJ1BiTyd5zrLKiSVo0mk7kUE8
         DMOIK70OlJfjf5MEMDGlbR4QiX9qCEk9zMcsn0j94/paeYm3zyatBuKDPUO/W2usoP+V
         FSFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=jImWSWSzvk0BYFosk8nq2RqkOLgHcmKoR4Zy5d6aQj4=;
        b=KcNunovSD4pgBRm8qXdwomxAssAL2x/W2wfhssu8+4UiMuY450/O1Qoci+UejQihsT
         5LO7O1vakx9TLxBS8k6NtAhATfefSz3i0tyo3UJiauGqxial5kP51RYIbKbLsJrC8shs
         AENTNaJ4bKCPZuIz1oZL1nx1txX/tnNAf0JtQyPsFshAU+gsDCzBim9RwYE/40HYaywg
         TjciWETAiFjQoXP+QPCJ+HLxR+/540kPQuzDBwqoNLIuGrFe8Nn6P+YVpCtAJhz4Yccm
         480cEHTnGyMAQ6YnIdykLz7BQe65LCzFQBnMgOfLJtm9z2/HjRG1Up3TROmcxTF+Vl0n
         NAdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 82si13306378pga.270.2019.02.12.10.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 10:22:39 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Feb 2019 10:22:38 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,362,1544515200"; 
   d="scan'208";a="115652316"
Received: from sikkaiax-mobl1.amr.corp.intel.com (HELO [10.7.201.139]) ([10.7.201.139])
  by orsmga006.jf.intel.com with ESMTP; 12 Feb 2019 10:22:36 -0800
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal
 RAM
To: Brice Goglin <Brice.Goglin@inria.fr>,
 Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: thomas.lendacky@amd.com, mhocko@suse.com, linux-nvdimm@lists.01.org,
 tiwai@suse.de, ying.huang@intel.com, linux-mm@kvack.org, jglisse@redhat.com,
 bp@suse.de, baiyaowei@cmss.chinamobile.com, zwisler@kernel.org,
 bhelgaas@google.com, fengguang.wu@intel.com, akpm@linux-foundation.org
References: <20190124231441.37A4A305@viggo.jf.intel.com>
 <20190124231448.E102D18E@viggo.jf.intel.com>
 <c4c6aca8-6ee8-be10-65ae-4cbe0aa03bfb@inria.fr>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <26ac36f4-7391-5321-217b-50d67e2119d7@intel.com>
Date: Mon, 11 Feb 2019 08:22:20 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <c4c6aca8-6ee8-be10-65ae-4cbe0aa03bfb@inria.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/9/19 3:00 AM, Brice Goglin wrote:
> I've used your patches on fake hardware (memmap=xx!yy) with an older
> nvdimm-pending branch (without Keith's patches). It worked fine. This
> time I am running on real Intel hardware. Any idea where to look ?

I've run them on real Intel hardware too.

Could you share the exact sequence of commands you're issuing to
reproduce the hang?  My guess would be that there's some odd interaction
between Dan's latest branch and my now (slightly) stale patches.

I'll refresh them this week and see if I can reproduce what you're seeing.


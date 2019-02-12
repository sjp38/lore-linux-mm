Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F4C4C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 19:59:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBCE6222C1
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 19:59:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBCE6222C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34E178E0002; Tue, 12 Feb 2019 14:59:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 325248E0001; Tue, 12 Feb 2019 14:59:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2142C8E0002; Tue, 12 Feb 2019 14:59:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id C25728E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 14:59:48 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id h79so1348911wme.3
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:59:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=IjzmFBhdim6dECDIk+JrSVdbZ49N+J/1PEzH2LKdzOg=;
        b=l06TDQTsM1XwpanjJrCXysnCxzuB2ZjL32CDWnxLSE9Yjc6WuLSqNfcJf5BO4msmUT
         SPCk+PU30wenldNTUZq4u2yzqnbl3NwIO3xfXUMfLNcbfVbbeVSs/+/igwplOUsXqezm
         NbknHPMkUb7NasS2szvOgckq9Lxdg6KAhp/dibng4VvitPQfddYUaAI0P7jgP6qbUGJp
         vbUtx2zWG7z49s2Ti7Mv6fh1WfV3t6+DFk9wtClN5GWhxCLc88Mswm++TnB+symZiapu
         edPWvoVdM4SH6olQPBxyJPsrTgNEfcx34XG5F6z3xhULBH/1X/LFv06e3EF94ie+9Wte
         zA8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: AHQUAuY+QDCEhzNLjE8IiNOfU/puKrExx39UgxJxYpm4vimGSwdZCfCD
	Me+KIl4h+kicWoDetVEXIwtwpxkAq407QCn0D36Fd+Cd523Qdk3xaeJVTGlcGor1HCRZ6J8ufg+
	9GMdekROEEBgAIJt2TmqhDpt/6nskzAnuY5hr1sNXnePRTaBcjJwizTMmHm7tHsXrPw==
X-Received: by 2002:a7b:c2a9:: with SMTP id c9mr491783wmk.44.1550001588302;
        Tue, 12 Feb 2019 11:59:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZvGQjtSH02C1wt0GXwN+LOpb0azu8sPuOm74YgPYmGoO9GF50nnhu1IVGpCvJwBbE4QKQh
X-Received: by 2002:a7b:c2a9:: with SMTP id c9mr491745wmk.44.1550001587499;
        Tue, 12 Feb 2019 11:59:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550001587; cv=none;
        d=google.com; s=arc-20160816;
        b=OH06ciVJHNHWTNM4/SYc9Eb6/wVXQDZpJ0TBI8D2a58ZQ9rJur785SxF2aMzxIE2sy
         QON1cDW4gA4hO1t8J39sjZGiSK7x0m84As2ji+ArvTvJ7w2Q759EFVs3O03JeaAK+1Qb
         q2K7zTp6wjwlKv8IGAERkCo+64mqHWaRZV46TzwCz+wdQVVYCqdUPjEDKxtXSTtN7TWg
         gAPDg8pRZlraN9nWOyGVoaBKCel3FjmR7d3LtX4zS5LNH5h+KYBmTv4ibZrPx4mW06NH
         A5xCcklCuTGuaTUeYwsKeW03MTXWY++OucbEZFxJQr30aZ7iQV09zYfIi0WhSXsWgAw8
         aIqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=IjzmFBhdim6dECDIk+JrSVdbZ49N+J/1PEzH2LKdzOg=;
        b=KA9BozdXn4FH4Lr1nq8Cy0+2UHi7iRPW2Vn7Qmn6wYxAcukeyEo4dNDldccYDH4hfL
         +pocPxzCOtFZziArp5bnMpqr9WRS3LtqpfIBGfWxAH0r+RZdfb4zDgVyk0fGKm4MU8HC
         BXFoV5GUHblKJlHQNqsFcKWoHNvp02V/Z4zWkAMPBtYTeOhO8HDJHjJ9kiAxS4rPfx2o
         V76RotINHpT9ZbUb9pDjq6Ar67qmLfPElAkMssecLG/silQgo+2yeZA8KR6Pm+liES2N
         yf0r6MqSH7vsnO6qtU3gU7CV6NzFJDJQ26m760Lavt4Hn8Cpp4yASoVAXr341UFtM8Nu
         2WGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id x7si2796062wru.417.2019.02.12.11.59.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 11:59:47 -0800 (PST)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) client-ip=192.134.164.104;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.58,362,1544482800"; 
   d="scan'208";a="295985158"
Received: from 91-160-5-165.subs.proxad.net (HELO [192.168.44.23]) ([91.160.5.165])
  by mail3-relais-sop.national.inria.fr with ESMTP/TLS/AES128-SHA; 12 Feb 2019 20:59:45 +0100
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal
 RAM
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org
Cc: thomas.lendacky@amd.com, mhocko@suse.com, linux-nvdimm@lists.01.org,
 tiwai@suse.de, ying.huang@intel.com, linux-mm@kvack.org, jglisse@redhat.com,
 bp@suse.de, baiyaowei@cmss.chinamobile.com, zwisler@kernel.org,
 bhelgaas@google.com, fengguang.wu@intel.com, akpm@linux-foundation.org
References: <20190124231441.37A4A305@viggo.jf.intel.com>
 <20190124231448.E102D18E@viggo.jf.intel.com>
 <c4c6aca8-6ee8-be10-65ae-4cbe0aa03bfb@inria.fr>
 <26ac36f4-7391-5321-217b-50d67e2119d7@intel.com>
From: Brice Goglin <Brice.Goglin@inria.fr>
Openpgp: preference=signencrypt
Autocrypt: addr=Brice.Goglin@inria.fr; prefer-encrypt=mutual; keydata=
 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
Message-ID: <453f13cd-a7fe-33eb-9a27-8490825ca29c@inria.fr>
Date: Tue, 12 Feb 2019 20:59:45 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <26ac36f4-7391-5321-217b-50d67e2119d7@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 11/02/2019 à 17:22, Dave Hansen a écrit :

> On 2/9/19 3:00 AM, Brice Goglin wrote:
>> I've used your patches on fake hardware (memmap=xx!yy) with an older
>> nvdimm-pending branch (without Keith's patches). It worked fine. This
>> time I am running on real Intel hardware. Any idea where to look ?
> I've run them on real Intel hardware too.
>
> Could you share the exact sequence of commands you're issuing to
> reproduce the hang?  My guess would be that there's some odd interaction
> between Dan's latest branch and my now (slightly) stale patches.
>
> I'll refresh them this week and see if I can reproduce what you're seeing.

# ndctl disable-region all
# ndctl zero-labels all
# ndctl enable-region region0
# ndctl create-namespace -r region0 -t pmem -m devdax
{
  "dev":"namespace0.0",
  "mode":"devdax",
  "map":"dev",
  "size":"1488.37 GiB (1598.13 GB)",
  "uuid":"ad0096d7-3fe7-4402-b529-ad64ed0bf789",
  "daxregion":{
    "id":0,
    "size":"1488.37 GiB (1598.13 GB)",
    "align":2097152,
    "devices":[
      {
        "chardev":"dax0.0",
        "size":"1488.37 GiB (1598.13 GB)"
      }
    ]
  },
  "align":2097152
}
# ndctl enable-namespace namespace0.0
# echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
<hang>

I tried with and without dax_pmem_compat loaded, but it doesn't help.

Brice


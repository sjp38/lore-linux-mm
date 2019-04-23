Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BABFAC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 20:40:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73805218B0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 20:40:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73805218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BE386B0003; Tue, 23 Apr 2019 16:40:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 146386B0005; Tue, 23 Apr 2019 16:40:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F29886B0007; Tue, 23 Apr 2019 16:40:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3D136B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 16:40:24 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t17so10949560plj.18
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:40:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=03WJD0N15V3XhIdCkFoR9nPQkQYoMQ82HGmFzeUzylI=;
        b=s8mnwwBqe93nJ89zSJMcFVUdHqEnQRCZHU5IXiEzSKY6+HZRYT13hfU0B5kVlpm932
         09ApyPC2YSH1tykT+jgtECfR+XjfI38oRjbS01gyTXj80nzzX/VmBldU874l5v4iuZkO
         3XD79IVIqXqVItvCMDfJSWmmmPG37LMXzEMnaj0cm7Rf1PdoJ/BXQkx2Xe48FLEUi5E8
         BfOgZaMTpbyDfmoBHCD30+9QIEg93CXAeGzd3uaJ+dhhIETA0X+jRsEetXif7D8JuZQI
         4pvcAoY0+gpa8IYDHl6mHu3CAN/BrzAxaCFhGIcfUePvPYmDuprf7NRqVznljnc/9X70
         m75Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXMwraB3R3rN9ARP+UPBk808Zv6v4ciXkcgk0PiDEI1yCFjCIIk
	rGkfn71me3n1EAUwV4xpc+dH/SEmN6Q38C0DzagGgLM1Tofr3id/jjE9nKaOpeahAulDg+cxla6
	a3Ci9FV5dWB7UdaJ7hCXPUp1BsLJXAFnyVW91vvPUe9aZviA7ACi3dGoEnQEhnxgosg==
X-Received: by 2002:a17:902:5609:: with SMTP id h9mr18430813pli.35.1556052024446;
        Tue, 23 Apr 2019 13:40:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5eEAczzlG4cKneK9BsadCgm6GXagaI/i1nIxfftTzkTRv17YZ0NflmpbrUPWell4VedJS
X-Received: by 2002:a17:902:5609:: with SMTP id h9mr18430765pli.35.1556052023845;
        Tue, 23 Apr 2019 13:40:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556052023; cv=none;
        d=google.com; s=arc-20160816;
        b=H6UJhPvI0kyUCR/fs6JZ8JIUX9/n9JPukOua0HHciVcKLuC7OsqWX7CvSV+UjWX6D3
         P1Na2TnSsu1Mckk+WXRLbjHlN6aLkdnAS5Q42AUcgzFV9PKuy5+hPuWkN/9oyjeV6Rmg
         SetK7BqLxEfrt08s6MdI0aSSu97wllKrfEUMHm00QG54ITu+0vp4Eo687HwC1RCkCIc1
         RNwiCoq5c1FaiNFIStcjt+mV19r1l4H2LSgVWZVW8ILGIoQQzb0uEb1WEXfJ04Tb/Z7M
         naSgC8b3m5SRQhMeh6fW3sV+HawkeZWspYeVyUe4LUw7FQF1Mz3aTCz7FaFEHyRfDrTx
         MzsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=03WJD0N15V3XhIdCkFoR9nPQkQYoMQ82HGmFzeUzylI=;
        b=q0rY/AMeMA6FRzscOyiNJmcSp0rMeIBTpAdHQrNo85rMfB3NqokwkoTNUF98RfJ6WD
         8l0qEJXva6JWeqMDBR1WZ5V8hkjr+/0ldXB6j7UCPHszcY7h30Cw4/UnQfzJSqWrVUd0
         8gBopjS8ME0Yeq/+ntzZl56/zsPVPOfS7iXMvtNGHxHGMcytpVv+69a1Gqon+9o1Otig
         fPO1+y3mDHmFZRMLaeIP49oqvBF7SZwpguKY2ztEh/z/unJNXKBNi5RC16kzrnGCn6ZB
         stbiwULmBDEv7+cwG9q/0soy1adffoTdJ4tEy3YtlgXxUeAReRjR+Ewv0TQpHOEM0kzd
         IKhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id l32si16322122pgm.130.2019.04.23.13.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 13:40:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Apr 2019 13:40:22 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,387,1549958400"; 
   d="scan'208";a="318347348"
Received: from ray.jf.intel.com (HELO [10.7.201.133]) ([10.7.201.133])
  by orsmga005.jf.intel.com with ESMTP; 23 Apr 2019 13:40:22 -0700
Subject: Re: [PATCH 2/3] gfp: mm: introduce __GFP_NOINIT
To: Kees Cook <keescook@chromium.org>
Cc: Alexander Potapenko <glider@google.com>,
 Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>,
 Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@redhat.com>,
 Linux-MM <linux-mm@kvack.org>,
 linux-security-module <linux-security-module@vger.kernel.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>
References: <20190418154208.131118-1-glider@google.com>
 <20190418154208.131118-3-glider@google.com>
 <7bf6bd62-c8e0-df3d-8e98-70063f2d175a@intel.com>
 <CAGXu5j+Lm0ba4ZQ91vZ8nZFvpJSxu_j_bEKMaa0NMsurmyZjjA@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <2c66e43f-81d5-ebeb-495a-f3f3b65d315c@intel.com>
Date: Tue, 23 Apr 2019 13:40:19 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+Lm0ba4ZQ91vZ8nZFvpJSxu_j_bEKMaa0NMsurmyZjjA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/23/19 12:14 PM, Kees Cook wrote:
>> These sl*b ones seem like a bad idea.  We already have rules that sl*b
>> allocations must be initialized by callers, and we have reasonably
>> frequent bugs where the rules are broken.
> 
> Hm? No, this is saying that the page allocator can skip the auto-init
> because the slab internals will be doing it later.

Ahhh, got it.  I missed all the fun in patch 1.


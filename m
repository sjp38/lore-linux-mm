Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83F7AC10F03
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:15:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2182F2083D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:15:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2182F2083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D5F06B0003; Mon, 25 Mar 2019 12:15:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95D706B0006; Mon, 25 Mar 2019 12:15:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FFFF6B0007; Mon, 25 Mar 2019 12:15:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8DF6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 12:15:14 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id k17so1351141wrq.7
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 09:15:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=nIIfGYqoye1pKvD66fGbvpQRHQm2R+NgjBIk8Cm7j8Y=;
        b=rLVNNp50deTkNyVqXNLU5n51Epp7THvJ1ioSbiQlYHhMX7MtBJjqgoaJA+XCwnLfHu
         a+k88aZ0irlUeYgKQJw8Feo/2+O1Jd5D/yMn4IRbtbFemQBpLDx3PRW7tEiBztWLZ3D0
         W4F2lM0dwZilM/Icie4lJ+Q0GSXujZxIl3PIeKxPopw7ucg8f8yJxIpEdad8SWBfBfV7
         Cd6jBV6Fnjp2mD9fEJkrtEdjDGrnlmaZswu69hspyDFRTp1UgYb0TeWP4hV60zYjIuH9
         3636YkwfwLDoVkhrKNKRaJX2ZGhnw7VS5yrhE2+0ThkpVj4t3OCmgp5DjZ5cj/AJvpvI
         /aMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: APjAAAUVHWrwyar+JKu22A78P+2jW2JCeWgAs5R/rmxWN0lHvzs1m0rt
	AUIbTYWkzLibFQwvJr3CqqqC9vFOIWA8tNe5Rv3s2JXNlKowcNciBt/5wVQKE91v7hbvUdsZrfq
	4UHkRSk7CtuahiCgeKWd5gOR/NOl5N1ftwDlduhmCGINNolom3cQlmVup34Hqg41P6g==
X-Received: by 2002:a1c:7e10:: with SMTP id z16mr8137324wmc.117.1553530513630;
        Mon, 25 Mar 2019 09:15:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2FCr4ReBJ0gCkWlW56ukyG2n/UgyPavQzSSUfGHg/IOoyd3x/2r33nG1tKnnV3QRqc6ut
X-Received: by 2002:a1c:7e10:: with SMTP id z16mr8137262wmc.117.1553530512612;
        Mon, 25 Mar 2019 09:15:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553530512; cv=none;
        d=google.com; s=arc-20160816;
        b=x3BBF2HMPi6s5YWb2JwXpR7p3AJIyWTbhASoQ7q/gnJH2oZPj1HCPC5Tm/Pl6XBZ1T
         4HqhjTO9EK5ulxb6xzBTSIEgWnTxKfgq9OXTi7YZeqKIRy5AD5QbAb66NKnJ906szRye
         napa3nIQLj7pYwLJ/0siSonwJ0PI2OQRB7NxTWLUPJxErWyAwBh96WFIu0M6WaaIqXdO
         vwzuMtndMeV451oWMGpHWCZUDxBrrItqWCtPR9ZetEPZ9JSPe7ov3K0LmSTEJBeTMUu7
         6+LO3UifdwneeeIanuqScf0d/oWYwdnj3Wnz8k57tUlzA1WP0jXm378lhJzamj6QQU1j
         kHbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=nIIfGYqoye1pKvD66fGbvpQRHQm2R+NgjBIk8Cm7j8Y=;
        b=jU8qSn0fddG8XGTpUiASlJIAIdOZnbm4SbLoLxiwSg86oOn28P0XOSXltkrc+g+5W+
         Ann4Msbj7mC7nLkBTsqx8SSvN0sNPNnkkwNjzzH3HfpoK8lCRHCWmoowTzZEjEoKhQEB
         /TOjA971sontHDW5FZdLh365Uuoso+DcTabVFufDkOpP5He+HT/NQ10xbrrffGiSh03O
         SdNSIqqy2MxHGbImyvZALXSdxkxrrO9z62Z9e8Fa/MHBuNJEKoK2bEAK2fyXpS7kqJ7Q
         Rs0RuatjBWbQMcQn1s2HdpWfwf2sZLQ8c6+/CtZZ6HJ4OBXcNw/5jUpAoPEqQSJ5qMZa
         6zJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id t10si9746186wmh.141.2019.03.25.09.15.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 09:15:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) client-ip=192.134.164.83;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.60,269,1549926000"; 
   d="scan'208";a="375668098"
Received: from unknown (HELO [193.50.110.144]) ([193.50.110.144])
  by mail2-relais-roc.national.inria.fr with ESMTP/TLS/AES128-SHA; 25 Mar 2019 17:15:11 +0100
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@suse.com,
 mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, dave.hansen@intel.com, keith.busch@intel.com,
 dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
 ying.huang@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
From: Brice Goglin <Brice.Goglin@inria.fr>
Openpgp: preference=signencrypt
Autocrypt: addr=Brice.Goglin@inria.fr; prefer-encrypt=mutual; keydata=
 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
Message-ID: <cc6f44e2-48b5-067f-9685-99d8ae470b50@inria.fr>
Date: Mon, 25 Mar 2019 17:15:11 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Le 23/03/2019 à 05:44, Yang Shi a écrit :
> With Dave Hansen's patches merged into Linus's tree
>
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308fd01d9fb33a16f64d2fd95f8830a4
>
> PMEM could be hot plugged as NUMA node now. But, how to use PMEM as NUMA node
> effectively and efficiently is still a question. 
>
> There have been a couple of proposals posted on the mailing list [1] [2].
>
> The patchset is aimed to try a different approach from this proposal [1]
> to use PMEM as NUMA nodes.
>
> The approach is designed to follow the below principles:
>
> 1. Use PMEM as normal NUMA node, no special gfp flag, zone, zonelist, etc.
>
> 2. DRAM first/by default. No surprise to existing applications and default
> running. PMEM will not be allocated unless its node is specified explicitly
> by NUMA policy. Some applications may be not very sensitive to memory latency,
> so they could be placed on PMEM nodes then have hot pages promote to DRAM
> gradually.


I am not against the approach for some workloads. However, many HPC
people would rather do this manually. But there's currently no easy way
to find out from userspace whether a given NUMA node is DDR or PMEM*. We
have to assume HMAT is available (and correct) and look at performance
attributes. When talking to humans, it would be better to say "I
allocated on the local DDR NUMA node" rather than "I allocated on the
fastest node according to HMAT latency".

Also, when we'll have HBM+DDR, some applications may want to use DDR by
default, which means they want the *slowest* node according to HMAT (by
the way, will your hybrid policy work if we ever have HBM+DDR+PMEM?).
Performance attributes could help, but how does user-space know for sure
that X>Y will still mean HBM>DDR and not DDR>PMEM in 5 years?

It seems to me that exporting a flag in sysfs saying whether a node is
PMEM could be convenient. Patch series [1] exported a "type" in sysfs
node directories ("pmem" or "dram"). I don't know how if there's an easy
way to define what HBM is and expose that type too.

Brice

* As far as I know, the only way is to look at all DAX devices until you
find the given NUMA node in the "target_node" attribute. If none, you're
likely not PMEM-backed.


> [1]: https://lore.kernel.org/linux-mm/20181226131446.330864849@intel.com/



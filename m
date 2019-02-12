Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00CCAC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:11:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B792221773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:11:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B792221773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33FBC8E0014; Tue, 12 Feb 2019 03:11:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EF2D8E0012; Tue, 12 Feb 2019 03:11:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DEAF8E0014; Tue, 12 Feb 2019 03:11:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE3338E0012
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 03:11:23 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id u74so734823wmf.0
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 00:11:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=wke/IuvxqEL7sp6gzPCjujvFdWt3Zk0jnxsCV2TJVjM=;
        b=g5oRnpAc3ilbeK1YFOTcwZjsputbqEQc5P2z+71dvTQUDFUwhwgLqSOU+fimruEeZ1
         G+d6BmQi+h6hhK2P8QTjTo6pAz9aa88CtbVqMQCTAMy3rBY3QR3jt58TBUG3cAIryu5i
         dQT9yzqSF92X5he/fZIA540sQjNsHqxzYj0U4xMwJLCNXXRnE5z4tR48CEp866ftisG3
         YFPGyA+M2RzPEFp3+KIAEEvJErBfTXZg8mbK0gGLMrHWUXW09wmZ+POZYaUZ9ovi/dle
         HRXgUlAqN7axVko4iYtrz9z1TBiGiAdyv/FTaXquVBsZVECfAa1JSQbxxxETUGqKB+Q2
         qGxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: AHQUAuY6rwp34qVX9YwB5p9j5onIWn/BtbR7UDVc21/EgrYe7zVv0mKz
	2wXcASmPbTXnGUwiDEB7Krb7ZsIaLYXGbBGbfYgQvk73/x1EUAdZ+YKv2Di0JTedCzmzrwOv0eZ
	/w97y60fWk7M135yrdCmuKfkzIo5zSoZ5PnywvQ4pMzhKUpm6bqJYievcbju6pt2WhA==
X-Received: by 2002:a1c:7dd6:: with SMTP id y205mr1710884wmc.121.1549959083342;
        Tue, 12 Feb 2019 00:11:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbYbgCuAnfGEagDL+oyK5NaRBgfPv8n/qy/MKMCNk3XFPu4YrQbgvSpBw4sIj7gkv+rot11
X-Received: by 2002:a1c:7dd6:: with SMTP id y205mr1710828wmc.121.1549959082359;
        Tue, 12 Feb 2019 00:11:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549959082; cv=none;
        d=google.com; s=arc-20160816;
        b=wmxVkuvobg0rialCI/KOZgKWESKOug32i5J1cI+ut84kIGCsaFH63qlBoscUrNyVKs
         Dy60BX+UxHKt+/tIbgiaKYCw70/VhoQ8SR9PPvMdAWZNRDAYhtLEq9lMwxFDqpHKbfie
         7iS4nCvENp0IK/3Cu4VAc8ejQttVOvy1zO1DoyVAUnalP5g0AjhCQW0YfEtmaMwi8JyH
         /CVbnqj9ii27WvjMBvScgMrwZoNyAhlQZLpRs4Ev86JsRpuZbrd7Vp8yWfxTP+PunG0d
         5jmNvHbRqJCsZjEjFEw4zF38wasv1XvB+Vof9aMBsxL9uZ2FbTDf6jr8k/urd6aQq0pL
         MIaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=wke/IuvxqEL7sp6gzPCjujvFdWt3Zk0jnxsCV2TJVjM=;
        b=uGHr+6NM+SSZqgiZnYnuunt11FllHVB2Ae2OHA3GnNShM6siy8zDkIdp68fk3lnXsc
         ZS7x51nRa1ohfpPo6Hq+i+45vatSuuRdiOMoJyEKFDG2R3mTW+dsz1lhG5YCe5dFeMTA
         F2MCAYVF5asblGtA0onsJMbwnz0+cxaTqau12/9Bcbk1YknB5W7FxHn0ljKMuguBDwPc
         QGVyLCkLLZCkkzIgOc0gwQl7Xd4/sahDQCE0YLYaknUK7YJO8sBZ7mFSndXdGkny/MhP
         sdOA9b+ru2VBWKMpzFkQEDV0p78frPyZzPBHnqekZDXzsgIn1EntKWSA8tGaQvC5e6te
         VnSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id l19si4150510wrf.400.2019.02.12.00.11.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 00:11:22 -0800 (PST)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) client-ip=192.134.164.83;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.58,361,1544482800"; 
   d="scan'208";a="369024966"
Received: from unknown (HELO [193.50.110.170]) ([193.50.110.170])
  by mail2-relais-roc.national.inria.fr with ESMTP/TLS/AES128-SHA; 12 Feb 2019 09:11:04 +0100
Subject: Re: [PATCHv4 10/13] node: Add memory caching attributes
To: Keith Busch <keith.busch@intel.com>,
 Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Rafael Wysocki <rafael@kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>,
 "Williams, Dan J" <dan.j.williams@intel.com>
References: <20190116175804.30196-1-keith.busch@intel.com>
 <20190116175804.30196-11-keith.busch@intel.com>
 <4a7d1c0c-c269-d7b2-11cb-88ad62b70a06@inria.fr>
 <20190210171958.00003ab2@huawei.com>
 <20190211152303.GA4525@localhost.localdomain>
From: Brice Goglin <Brice.Goglin@inria.fr>
Openpgp: preference=signencrypt
Autocrypt: addr=Brice.Goglin@inria.fr; prefer-encrypt=mutual; keydata=
 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
Message-ID: <854e892c-0c0d-6ab8-bc83-3c6b462bcf72@inria.fr>
Date: Tue, 12 Feb 2019 09:11:03 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190211152303.GA4525@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Le 11/02/2019 à 16:23, Keith Busch a écrit :
> On Sun, Feb 10, 2019 at 09:19:58AM -0800, Jonathan Cameron wrote:
>> On Sat, 9 Feb 2019 09:20:53 +0100
>> Brice Goglin <Brice.Goglin@inria.fr> wrote:
>>
>>> Hello Keith
>>>
>>> Could we ever have a single side cache in front of two NUMA nodes ? I
>>> don't see a way to find that out in the current implementation. Would we
>>> have an "id" and/or "nodemap" bitmask in the sidecache structure ?
>> This is certainly a possible thing for hardware to do.
>>
>> ACPI IIRC doesn't provide any means of representing that - your best
>> option is to represent it as two different entries, one for each of the
>> memory nodes.  Interesting question of whether you would then claim
>> they were half as big each, or the full size.  Of course, there are
>> other possible ways to get this info beyond HMAT, so perhaps the interface
>> should allow it to be exposed if available?
> HMAT doesn't do this, but I want this interface abstracted enough from
> HMAT to express whatever is necessary.
>
> The CPU cache is the closest existing exported attributes to this,
> and they provide "shared_cpu_list". To that end, I can export a
> "shared_node_list", though previous reviews strongly disliked multi-value
> sysfs entries. :(
>
> Would shared-node symlinks capture the need, and more acceptable?


As a user-space guy reading these files/symlinks, I would prefer reading
a bitmask just like we do for CPU cache "cpumap" or CPU "siblings" files
(or sibling_list).

Reading a directory and looking for dentries matching "foo%d" is far
less convenient  in C. If all these files are inside a dedicated
subdirectory, it's better but still not as easy.

Brice



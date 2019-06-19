Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66F29C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 22:50:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28F1F2085A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 22:50:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28F1F2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A35398E0001; Wed, 19 Jun 2019 18:50:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E5186B0005; Wed, 19 Jun 2019 18:50:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AF4A8E0001; Wed, 19 Jun 2019 18:50:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56B906B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:50:47 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w31so364172pgk.23
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 15:50:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:from
         :subject:openpgp:autocrypt:message-id:date:user-agent:mime-version
         :content-language:content-transfer-encoding;
        bh=cg+usQt5kk+VASiNHyDpogLWvEhdBLb+Y6C/AS6MrIo=;
        b=C3Q+StTEv7vAbhJ9vUM7E6PNJ6JTeM8fAMUbT5Z/eSFpatMBm+tUZAysh+5NwKwAlT
         yT87L1WaLo13CIO0boSBOcOTcdYoFruBlL9uo3nnMwV1pqPfektKBVpIk7c2xwhwPmfU
         GSy9fpDjwyA7LCMuEdFO+npsyy8KDY2IQmwyMZnXMMPqBxHlCJ7UCP3eyqwf2Sf8xDd2
         tBLOqnpEBDIdtBMOZ29Gl5D9FU/2QpkRTrue/mSpQBUx7CWG9Cewp7mkQ/u+DY6xRqU6
         Y7i++nyTTxq8WalLhuv8DsMSF3fd/i3OR3h/uevNnauAMJWpagBlhml7q7DeEuxNwr4K
         7G6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWqBDMWsgpfo6p9C5kiTvqTqwJ5v4ewaWQhvAfbMmOtZ6bqcP86
	m685F+nqjqCw8Xw1gEys8Cbg/X+3B2xub8wIxzBRw4fAWmSN91C4wX6snN6Ov6Bb8/9nTwhqMNR
	ouwF/AmIY0TTuHozDLyDd6BKwIruzaidcR3LFMBFeZAROvDC6+z8/t5/6w7kmlB7ItA==
X-Received: by 2002:a63:5d25:: with SMTP id r37mr9565653pgb.449.1560984646889;
        Wed, 19 Jun 2019 15:50:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+UmIBjVfyIYjJmwAiL76vgq+bQtWOEz7n42tyEKvDxm4jmBOVPnAS0TVe7GvU1Bn2OxZA
X-Received: by 2002:a63:5d25:: with SMTP id r37mr9565613pgb.449.1560984646200;
        Wed, 19 Jun 2019 15:50:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560984646; cv=none;
        d=google.com; s=arc-20160816;
        b=HZpZ/qdUiXi46u3ZqkLHynTGPHf+nERgGeUw5UClmFLVMjsXSFsoqEut6TkrNW68gb
         G4c/Fe2RjpZf1tVmjrLPUCj4ORUJlKC4Kg83k1fBDaDNJdk7YcXjthbqwD8nMKgGuvq3
         8E8cd+I11P2go2LHPwCS4xrPaevhh0B9KHfnr7bg5GOHP3UUPwFfBn5m/3yTOWmJ1MfM
         8702jhhefBmQGcJ7/ksx7GMuclfe0UnHXXLsYGGmAo5W4bvqvRoQDPNGuk7/jFZc75VV
         9Lc1zw1y9EfO8RP0Pmwea58Za6Ia+UWpbwd88UnNLz8tTEXghtqFEfyR+vjqYGhwYdm3
         Gqiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:autocrypt:openpgp:subject:from:to;
        bh=cg+usQt5kk+VASiNHyDpogLWvEhdBLb+Y6C/AS6MrIo=;
        b=gIeYejjZoOhaa4Ck8zXNHQSmlDnUmgD+rsk+bTo0QsNQsH1NfKil5u6TMg1kpqWqCW
         c1PB0dxiVXbtsSBiSCR0tCUiH1TIggg8AcL+SSRILLkVxX4RcZx161JqmqA51XReYMfE
         w5CUX6enjrVOklvUnKkvGQrXjC/f3LaQvgkd8VUuMnqW51JPwyKMgqgeVJYmAlaRn8I/
         5kyrc7ChBpnIMGFgfUG6GUzFl0ow7Wf7K9koB4O2nO7tjZt0pMfRfYHAHmkk2n2gw85w
         PtuqDJpAd6D6SgnoXF6rMzEVTy2jdSuSiJYmWQ6PDlqIuLY5sd30qpn47DOUd/p/JVm9
         o6YQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id v7si16082456plo.9.2019.06.19.15.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 15:50:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Jun 2019 15:50:45 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,394,1557212400"; 
   d="scan'208";a="170696577"
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga002.jf.intel.com with ESMTP; 19 Jun 2019 15:50:45 -0700
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
 linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>,
 "Williams, Dan J" <dan.j.williams@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Subject: memcg/kmem panics
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <e5cfe17c-a59f-b1d1-19ce-590245106068@intel.com>
Date: Wed, 19 Jun 2019 15:50:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I have a bit of a grievance to file.  :)

I'm seeing "Cannot create slab..." panic()s coming from
kmem_cache_open() when trying to create memory cgroups on a Fedora
system running 5.2-rc's.  The panic()s happen when failing to create
memcg-specific slabs because the memcg code passes through the
root_cache->flags, which can include SLAB_PANIC.

I haven't tracked down the root cause yet, or where this behavior
started.  But, the end-user experience is that systemd tries to create a
cgroup and ends up with a kernel panic.  That's rather sad, especially
for the poor sod that's trying to debug it.

Should memcg_create_kmem_cache() be, perhaps filtering out SLAB_PANIC
from root_cache->flags, for instance?  That might make the system a bit
less likely to turn into a doorstop if and when something goes mildly
wrong.  I've hacked out the panic()s and the system actually seems to
boot OK.

BTW, this particular system has some persistent memory in it.  I suspect
there's something wrong where the slab code is trying to create slabs
for pmem-only nodes.  But,


Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07535C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 19:06:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 950E32054F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 19:06:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 950E32054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB7A96B0005; Thu, 18 Apr 2019 15:06:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E40726B0006; Thu, 18 Apr 2019 15:06:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE2756B0007; Thu, 18 Apr 2019 15:06:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 911B06B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:06:21 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a3so1930865pfi.17
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 12:06:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=QDnkIqgDCK+jGplDKmI5MM5U60+QK1T6N3YzHr7HOMY=;
        b=O9IkqTcqSotSgG3OkUJX982U10kAqxFsg558AnouMOzvgsTy+6MW4e798lLRa1U2u+
         CzuROlJS/rRCdwboR7rH/VOr/YAg5XlBSbflCltfQyT+a088BbTs6oXPvF9RQttr6p3i
         D9kUJN6Y+K9iKwF6OZ8E/M+JObDGTklPHr84c7IitFR5b8OhxIBLhaHyWbAqMHpGxpon
         LU4Pa7MiWGIJoVW4sfoILU/H8+8n+DKI2MbUs7PzY93diWkpBkvvmlZTxgiBeGvPzGEk
         OM4sLfl3I7jR56N986WPG8I+ftO34m/xP1ZnBExqR6CMJAxuTlE7y2MtB9enFTOQXjl9
         sO3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWBMw+y7VQQg17ZfjvlLuo+teJKvsqsbbAJF0fJegr+iNRV0R2C
	masNcKNjLjDPP3m4juj4B53r6Y+J3091POWnDoxgUhSHAfp40xBSjv7N9hZZK0NHeF5+6XEJ5A9
	EVR8fOdKdpK4bEbR6eLKraUdoIqZp4Y9UDuJBA1hgZPzlElVTawpuzsIbJJ9GYaHaqQ==
X-Received: by 2002:a65:424d:: with SMTP id d13mr9886077pgq.318.1555614381264;
        Thu, 18 Apr 2019 12:06:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/YrljC7M5s//eCMTA27dKf4L0KD+VhBHBlYJ1K4XPu3EVWZeM9MTvPBaDTDWklj4EH4tm
X-Received: by 2002:a65:424d:: with SMTP id d13mr9885975pgq.318.1555614380054;
        Thu, 18 Apr 2019 12:06:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555614380; cv=none;
        d=google.com; s=arc-20160816;
        b=qpoamoHZMxqUP74J4W+opHuKKrMz6M3n2guykZf8xpSDBPBVde+I4Kg0nE3neTorhp
         0aGxxIcNcw1b9KW83NCIkyiMxY50EKJJNXOQSbubsMbDe2hvs1sRuEeI9DOEZMp99ff0
         pB2KUgK3asgP4w7LvXG25ri28pQI/ZUVXEIfnk7bO3kgsxAt7YXie8DxWnGT1DFwdKK8
         zrBHf9lAxiubvoxS6tmUTU1t+BmRBrSrSl/LoaWxPZ+WSWi71R1n1xFU2jxIVUVCYUT2
         grRaw3KmnpmdTf+ktwImJi+NZWTjGDlPGxbpKrLeZ7RQd/X0K3WuMcVU/Jt1A9HgHJD3
         6XGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=QDnkIqgDCK+jGplDKmI5MM5U60+QK1T6N3YzHr7HOMY=;
        b=e8oy5G1t6qhf9a6sJ56jDgpxb0zdDHhf9dD6KqCkeJf5W8aIs6xyjfkj1WUBeLVHb+
         w8afEV5xItANT1BfxP3QnED/0jXKbOTCAWcqcRrU8Nq3nMzgQCub12wPdBDQ9zY0rp5R
         YFimag/jpHTs0DGCes6YC4hgHgKlwwoFAoP4C3ttCBr64I8IvL5vIgExp9/o1ImQrE+F
         u2AqgxYcF7U6nOol8HQykl+As08nXluYOikuj2L3jZgVSNnltQ6t8Vm2V8uTPBx4Ksm4
         4I65KVm8wLZuirhxjEY0vXk5skBF0Xc4uBAjEELS8wc3/2/MOtbmaT3aPBaptjW20112
         DPOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 2si2683436pld.334.2019.04.18.12.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 12:06:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Apr 2019 12:06:18 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,367,1549958400"; 
   d="scan'208";a="224713233"
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga001.jf.intel.com with ESMTP; 18 Apr 2019 12:06:18 -0700
Subject: Re: [tip:x86/urgent] x86/mpx: Fix recursive munmap() corruption
To: Sasha Levin <sashal@kernel.org>,
 tip-bot for Dave Hansen <tipbot@zytor.com>, linux-tip-commits@vger.kernel.org
Cc: dave.hansen@linux.intel.com, tglx@linutronix.de, mhocko@suse.com,
 Vlastimil Babka <vbabka@suse.cz>, Andy Lutomirski <luto@amacapital.net>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 stable@vger.kernel.org
References: <tip-508b8482ea2227ba8695d1cf8311166a455c2ae0@git.kernel.org>
 <20190418182927.A78AB217D7@mail.kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <09aa9f89-14e1-a188-057b-592e2fc845e6@intel.com>
Date: Thu, 18 Apr 2019 12:06:18 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418182927.A78AB217D7@mail.kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 11:29 AM, Sasha Levin wrote:
> This commit has been processed because it contains a "Fixes:" tag,
> fixing commit: 1de4fa14ee25 x86, mpx: Cleanup unused bound tables.
> 
> The bot has tested the following trees: v5.0.8, v4.19.35, v4.14.112, v4.9.169, v4.4.178.
> 
> v5.0.8: Build OK!
> v4.19.35: Failed to apply! Possible dependencies:
>     dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")

I probably should have looked more closely at the state of the code
before dd2283f2605e.  A more correct Fixes: would probably have referred
to dd2283f2605e.  *It* appears to be the root cause rather than the
original MPX code that I called out.

The pre-dd2283f2605e code does this:

>         /*
>          * Remove the vma's, and unmap the actual pages
>          */
>         detach_vmas_to_be_unmapped(mm, vma, prev, end);
>         unmap_region(mm, vma, prev, start, end);
> 
>         arch_unmap(mm, vma, start, end);
> 
>         /* Fix up all other VM information */
>         remove_vma_list(mm, vma);

But, this is actually safe.  arch_unmap() can't see 'vma' in the rbtree
because it's been detached, so it can't do anything to 'vma' that might
be unsafe for remove_vma_list()'s use of 'vma'.	

The bug in dd2283f2605e was moving unmap_region() to the after arch_unmap().

I confirmed this by running the reproducer on v4.19.35.  It did not
trigger anything there, even with a bunch of debugging enabled which
detected the issue in 5.0.


Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A80AC3A59E
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 19:34:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 323A520674
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 19:34:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="G7z0JoJA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 323A520674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A13EE6B0003; Mon,  2 Sep 2019 15:34:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C3EA6B0005; Mon,  2 Sep 2019 15:34:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 865B66B0006; Mon,  2 Sep 2019 15:34:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0221.hostedemail.com [216.40.44.221])
	by kanga.kvack.org (Postfix) with ESMTP id 6495F6B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 15:34:33 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D669F180AD7C3
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 19:34:32 +0000 (UTC)
X-FDA: 75890982384.13.knife57_7ef3ba079e117
X-HE-Tag: knife57_7ef3ba079e117
X-Filterd-Recvd-Size: 5050
Received: from mail-lf1-f67.google.com (mail-lf1-f67.google.com [209.85.167.67])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 19:34:32 +0000 (UTC)
Received: by mail-lf1-f67.google.com with SMTP id w6so5710656lfl.2
        for <linux-mm@kvack.org>; Mon, 02 Sep 2019 12:34:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=bGRyo55Grqjgw6KDZGiTGmb9hZemVetuNkxEfZG9oYg=;
        b=G7z0JoJAYy37w3VV/CgWWddE8KL+oLKTSQI0QgFPQ9hN+10YbJwiju/xqiFy4sBTzI
         M6aKDgfaSBwS7/5J05zM+k42sovpEZVIEaJ2bgpTMViytUmNbBymPBEVcXFC9YSJ2DZq
         DU0Ax2Zw5CfIiufCxY8Zh4tSdHuHWnjTNfLAxsvqTpjdFrhT4ghbriTggztIidQGrdGM
         fGIqBJvBb+h0OVa5yBHWHZUwwIpY7wvuFXnR7LP2v9kkom0L/V87DvAn4q89IAWyu/m+
         YHpn1LLr1JL926BGz7fffWKJxoItVSI0vrWwlYVRCPtHFRvFjBUMgI89X28yGW7Zs7bS
         xA6A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=bGRyo55Grqjgw6KDZGiTGmb9hZemVetuNkxEfZG9oYg=;
        b=AM/sxTO5fP/ALynJNS0Tc+1BhPqfglneIfmAs7t4zlXpa4dK8kRfE3WAmXr74HhCDt
         EjwN5W85EmTOWKyoSBnboMI9R7zJc+OVkO+fRuM2vaj8Ab9Xz63RDhPCqXPAUOprof04
         FEQq7Rt5mHKXC/fljQokihVToIPqWcGjm3wvtPIj9ulykeF9kIZ1zWkcnZC34q5hhgzz
         UxU5VD4jyeCvKYwJCfCqNVN8/2TUttVLbBeJRpy4x8A3gdmL1H0hg9C23uYH2bRdlmdN
         E/JJS+gcLOGGJky31guABhCcMyT7i8837mZH5jtZxbPsyIcgW3gSGglXQdbqhJDlrbC9
         LzHQ==
X-Gm-Message-State: APjAAAVb0f7rFw0haWWWsvXF6jI1h/F1y8hclaHA6NxK5wp/mWvzB0tC
	La5IRtW6dkj1XeCq3CJn0+w=
X-Google-Smtp-Source: APXvYqzbas2dakjU1oMyYKQ4EruEVWImpf4syEuKbV9b8Sw/3Fk3CjDA4OMiZnmZg/0SNDHfjW9o3Q==
X-Received: by 2002:a19:beca:: with SMTP id o193mr18399333lff.137.1567452870845;
        Mon, 02 Sep 2019 12:34:30 -0700 (PDT)
Received: from [84.217.160.234] (c-8caed954.51034-0-757473696b74.bbcust.telenor.se. [84.217.160.234])
        by smtp.gmail.com with ESMTPSA id c21sm173243ljj.6.2019.09.02.12.34.30
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 02 Sep 2019 12:34:30 -0700 (PDT)
Subject: Re: [BUG] Early OOM and kernel NULL pointer dereference in 4.19.69
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, stable@vger.kernel.org
References: <31131c2d-a936-8bbf-e58d-a3baaa457340@gmail.com>
 <20190902071617.GC14028@dhcp22.suse.cz>
From: Thomas Lindroth <thomas.lindroth@gmail.com>
Message-ID: <a07da432-1fc1-67de-ae35-93f157bf9a7d@gmail.com>
Date: Mon, 2 Sep 2019 21:34:29 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190902071617.GC14028@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/2/19 9:16 AM, Michal Hocko wrote:
> On Sun 01-09-19 22:43:05, Thomas Lindroth wrote:
>> After upgrading to the 4.19 series I've started getting problems with
>> early OOM.
> 
> What is the kenrel you have updated from? Would it be possible to try
> the current Linus' tree?

I did some more testing and it turns out this is not a regression after all.

I followed up on my hunch and monitored memory.kmem.max_usage_in_bytes while
running cgexec -g memory:12G bash -c 'find / -xdev -type f -print0 | \
         xargs -0 -n 1 -P 8 stat > /dev/null'

Just as memory.kmem.max_usage_in_bytes = memory.kmem.limit_in_bytes the OOM
killer kicked in and killed my X server.

Using the find|stat approach it was easy to test the problem in a testing VM.
I was able to reproduce the problem in all these kernels:
   4.9.0
   4.14.0
   4.14.115
   4.19.0
   5.2.11

5.3-rc6 didn't build in the VM. The build environment is too old probably.

I was curious why I initially couldn't reproduce the problem in 4.14 by
building chromium. I was again able to successfully build chromium using
4.14.115. Turns out memory.kmem.max_usage_in_bytes was 1015689216 after
building and my limit is set to 1073741824. I guess some unrelated change in
memory management raised that slightly for 4.19 triggering the problem.

If you want to reproduce for yourself here are the steps:
1. build any kernel above 4.9 using something like my .config
2. setup a v1 memory cgroup with memory.kmem.limit_in_bytes lower than
    memory.limit_in_bytes. I used 100M in my testing VM.
3. Run "find / -xdev -type f -print0 | xargs -0 -n 1 -P 8 stat > /dev/null"
    in the cgroup.
4. Assuming there is enough inodes on the rootfs the global OOM killer
    should kick in when memory.kmem.max_usage_in_bytes =
    memory.kmem.limit_in_bytes and kill something outside the cgroup.


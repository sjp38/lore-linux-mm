Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28BBBC04AB1
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 01:54:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B229A217F4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 01:54:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B229A217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BDEC6B0003; Thu,  9 May 2019 21:54:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26F286B0006; Thu,  9 May 2019 21:54:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15F2A6B0007; Thu,  9 May 2019 21:54:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D1A066B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 21:54:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so2939427pfn.8
        for <linux-mm@kvack.org>; Thu, 09 May 2019 18:54:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding;
        bh=9rR0wny9DL1OwTEt7uVK9I1Hpj+YXsOIQ38J5T0X7cE=;
        b=LFzoHfN3qHwhQ13DxKCuH6TrneFoYEKLzq87I7Mp3JB8HCYnnZLYDbNAO+zLGqqz5J
         kq5+8Y8zCZ4uQ1FaYlE1Xv/eI8Pm3hh3Uf0LOXNw/XfyS84XQlX/nGUk6V5sLf5zsKnP
         KQmdRr39uXFRok7Yy8LWp2j2FbTmK3tkuzkRqC44Xv0dT4oOtr9N8t/5JdL3uvRr7htb
         GSHRlgOhjfgQFJJ+1iCcKXENUSSELP9V9UOTH5wA7QP+qShsgCC/NS1am4ValW4+z6Cn
         A67hw2vjyjlQnRxvrhe+qhn97y/+EiTjEJ+YG4MubDdtFTmgvSwff6g0r3cxe421cFVZ
         sWTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhangliguang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=zhangliguang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUgVqkRZoFNg28vDRcWGSAaj+4J4G6bx6mfJRVCYxKRmyrCFyB1
	lDpJYJtdUILlHLYriAx+D/gnaoaqCEUNmKZs/vBUaWoNr7/GHqemb/koy2gl26OWlgZVBi5IHi1
	wDCTa+/+2IcGMCdjXDg6sNcCVSgl0/W+rmD4gouOkdcewoC7H8wnx6hVsU9qzj1AlQg==
X-Received: by 2002:a17:902:e086:: with SMTP id cb6mr9572862plb.237.1557453271465;
        Thu, 09 May 2019 18:54:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+nk6VOIyNWyJjUZmYgAp1qP/6fS4uKjXsajkG20ezISMal4LHM69XBLpNjgO6lRb7vQfF
X-Received: by 2002:a17:902:e086:: with SMTP id cb6mr9572777plb.237.1557453270618;
        Thu, 09 May 2019 18:54:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557453270; cv=none;
        d=google.com; s=arc-20160816;
        b=lp3iPxZrqpv25D3GA3QJMTsE2ScTeIXBaPxRtQIgPFuftFxbpQ14a7A+9eiKSH8MYx
         kFfwGLMVqExt/pe0k1aotlWGUujDOAG/0bc/JWSVoJQYhtK5lXZbmuMAkd/UaE3Yyce+
         wkMljyB/zz1ZnI0PVzdoUN3eAZGro55yZF9OyRZ9xPFE2S039HOptFav2prwOBonkCwh
         R57RYiwQnReSEB+5uNnhUvCoVTkftpkigWgMrUdDHHJLavDk7A2pW2WaBkuHEO5Aljal
         ARToONDLHGdaZKsZc1KaHMPmI4OCp/+JtYGXhrAJQ+W8SPkUnoHyIq772o/VB+dL7tFM
         /Tgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject;
        bh=9rR0wny9DL1OwTEt7uVK9I1Hpj+YXsOIQ38J5T0X7cE=;
        b=lOkvMSHBPl8aaOh/1CdAQT9rHoSBahSLwY/9ELBGCNQ4j3ZCu9QIFfyTP4nfcNOUkM
         46OxfHAG6wERP3lTvdPuaxXwNZ/MWUnqT8r7BItjNQMmgNflyb9bsEo6HDklIuyNl5T2
         L/kCfa82X711eO2eqB/jKd8tVBHiie/cJ3uvYlwfbO1P0EaFI+FLU6MnrOr0VDgeu1hp
         z8RsVuFdqebncuuCnJhdRTUYqRtjYzojcRJhxDAjOPrIdG/FKxy+AVXX4SnjHUI2klwe
         CG31H+ghAdKtXkbFuxdzrtEeKHtlrTGrtQbzPJ+P6q59A5rj1IftJC1XqNZ4koG4FbZW
         BYwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhangliguang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=zhangliguang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id 33si5693991pgt.52.2019.05.09.18.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 18:54:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhangliguang@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhangliguang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=zhangliguang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R121e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=zhangliguang@linux.alibaba.com;NM=1;PH=DS;RN=4;SR=0;TI=SMTPD_---0TRINaUb_1557453267;
Received: from 30.5.116.80(mailfrom:zhangliguang@linux.alibaba.com fp:SMTPD_---0TRINaUb_1557453267)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 10 May 2019 09:54:28 +0800
Subject: Re: [PATCH] fs/writeback: Attach inode's wb to root if needed
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, cgroups@vger.kernel.org, linux-mm@kvack.org
References: <1557389033-39649-1-git-send-email-zhangliguang@linux.alibaba.com>
 <20190509164802.GV374014@devbig004.ftw2.facebook.com>
From: =?UTF-8?B?5Lmx55+z?= <zhangliguang@linux.alibaba.com>
Message-ID: <a5bb3773-fef5-ce2b-33b9-18e0d49c33c4@linux.alibaba.com>
Date: Fri, 10 May 2019 09:54:27 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190509164802.GV374014@devbig004.ftw2.facebook.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Tejun,

在 2019/5/10 0:48, Tejun Heo 写道:
> Hi Tejun,
>
> On Thu, May 09, 2019 at 04:03:53PM +0800, zhangliguang wrote:
>> There might have tons of files queued in the writeback, awaiting for
>> writing back. Unfortunately, the writeback's cgroup has been dead. In
>> this case, we reassociate the inode with another writeback cgroup, but
>> we possibly can't because the writeback associated with the dead cgroup
>> is the only valid one. In this case, the new writeback is allocated,
>> initialized and associated with the inode. It causes unnecessary high
>> system load and latency.
>>
>> This fixes the issue by enforce moving the inode to root cgroup when the
>> previous binding cgroup becomes dead. With it, no more unnecessary
>> writebacks are created, populated and the system load decreased by about
>> 6x in the online service we encounted:
>>      Without the patch: about 30% system load
>>      With the patch:    about  5% system load
> Can you please describe the scenario with more details?  I'm having a
> bit of hard time understanding the amount of cpu cycles being
> consumed.
>
> Thanks.

Our search line reported a problem, when containerA was removed,
containerB and containerC's system load were up to 30%.

We record the trace with 'perf record cycles:k -g -a', found that wb_init
was the hotspot function.

Function call:

generic_file_direct_write
    filemap_write_and_wait_range
       __filemap_fdatawrite_range
          wbc_attach_fdatawrite_inode
             inode_attach_wb
                __inode_attach_wb
                   wb_get_create
             wbc_attach_and_unlock_inode
                if (unlikely(wb_dying(wbc->wb)))
                   inode_switch_wbs
                      wb_get_create
                         ; Search bdi->cgwb_tree from memcg_css->id
                         ; OR cgwb_create
                            kmalloc
                            wb_init       // hot spot
                            ; Insert to bdi->cgwb_tree, mmecg_css->id as key

We discussed it through, base on the analysis:  When we running into the
issue, there is cgroups are being deleted. The inodes (files) that were
associated with these cgroups have to switch into another newly created
writeback. We think there are huge amount of inodes in the writeback list
that time. So we don't think there is anything abnormal. However, one
thing we possibly can do: enforce these inodes to BDI embedded wirteback
and we needn't create huge amount of writebacks in that case, to avoid
the high system load phenomenon. We expect correct wb (best candidate) is
picked up in next round.

Thanks,
Liguang

>


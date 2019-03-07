Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B16CC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 14:17:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D76320835
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 14:17:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D76320835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axis.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1D328E0003; Thu,  7 Mar 2019 09:17:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCD458E0002; Thu,  7 Mar 2019 09:17:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6F2D8E0003; Thu,  7 Mar 2019 09:17:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 358D88E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 09:17:33 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id q6so1969191lfb.7
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 06:17:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=mMgBAg3FDLZyZhQXZas9Mw6YWkYWVB5xf/fzV+lQdn4=;
        b=A36vnSDt1izmSbBTE79nBsMykm4a1aM5c51PcMb89cKnTYYHrckUJD//wq4A24CYSb
         MGIA+kbx3kX69qY70YyZxJE9MQhwUSr4yIEkTgIlRj/VzOfRGC9BmkeyTgTptHFWErLw
         +HsA496WKaMv0t81PftYBQWkY4nj3r+3XZEvFtiAjtJ9rNbWyPh/MjKms8q4sHxqiTLw
         z9DWPxKl3mLPUDNiy/JPhXyLheOExeLcMhenv+2LwEj1Nso0BKOnqXACcDjsFMSFh43x
         n7wnCL8PcZbf/Y9/PLbzC1mKxxE883H4mkuH6y5HcFOnlFqzISE51H6rq1GcYokZesbB
         94PA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
X-Gm-Message-State: APjAAAXTCcsakFwe1Rueh3A/M2LHad9Kr5RfiF5UDJy5Dd3g/WvjzxlF
	z3c8JFlA18zd81NmuuVV0dwDIZCFM4t3kJPVxf76Tfjs02npCEmnOO37ZRYnFfFYwVKHDaGli9h
	SkJ9gEpXIv6P1LeQYZEaDPeFLr6XjrCLO2dukWg9qe2pJ8SBo8YGD02x6eEaUNvEipQ==
X-Received: by 2002:a19:4f53:: with SMTP id a19mr6610075lfk.99.1551968252666;
        Thu, 07 Mar 2019 06:17:32 -0800 (PST)
X-Google-Smtp-Source: APXvYqzaLZAMsuPwsrzRxFvLAUAjWXfdN4NvA5z+iUzQX4rsgHmCWiTxU+jgFUVxaiBqsZmpDyqY
X-Received: by 2002:a19:4f53:: with SMTP id a19mr6610028lfk.99.1551968251646;
        Thu, 07 Mar 2019 06:17:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551968251; cv=none;
        d=google.com; s=arc-20160816;
        b=G6IRY0EZzTpMgwRT8003pyIICSikkMDmWQ1pgJ0NUpjvHxdZ8ANAn9p2vYloJpeI+e
         97IlfD16wDl7m5snBHfYS/2aDRmHBppzG/crl4wsFqeXIeoyKZtW23zcpC4fjz9srBHZ
         6prHVK63MhBObfGXe8rwHqqBlPQYxkX0cDbXWeirvS+FT61VmTabeQBCz/LephUb0HAG
         +Th9xOhfmkD+sopnzwjR7GmlWo0BFPgutRAGQGjQrxWJLpuBdPnX9rMehMMShx32j4Ne
         n+IPL1STYo5berOGi+9bWfIam7Dv1+TPOxMwmpGVmIcfXi1fn4AYOv9DmVdM95Ri9uZR
         bjmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=mMgBAg3FDLZyZhQXZas9Mw6YWkYWVB5xf/fzV+lQdn4=;
        b=EkFMfz3jAFaq8dchBsWrbvl7JsaiMPsHp5QcUVTMcbk1OmPm8ojt1VMD/zN2c8KEYP
         HVMCt8oPfdup0mAp2fbH+XIIOQ/fKIgU/0ozJxwXKK3nBzsuSTgwjXzG5vJXj6XgNeCQ
         Y4sjWyoVtrW9V+mdoFWEiwE8ksZhQAqaBMxUj6zpRZdZebSHvOOCaTfZ41tlE/nJrBRg
         gf9gvZi5tA4vQJhhSXXTUGu92grzFSGR3/HgubLgywGxVnyRxDhU3CCsa4W77wlh2p3I
         p5mFcbo5Cz+s2vXRdaeemxZ3kgIdxom4JET0/bHv/P3O6+qOcE8nidefkIFDKyPlPh1J
         iVIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id a28si3627211lfk.18.2019.03.07.06.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 06:17:31 -0800 (PST)
Received-SPF: pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) client-ip=195.60.68.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
Received: from localhost (localhost [127.0.0.1])
	by bastet.se.axis.com (Postfix) with ESMTP id 3164A185C5;
	Thu,  7 Mar 2019 15:17:31 +0100 (CET)
X-Axis-User: NO
X-Axis-NonUser: YES
X-Virus-Scanned: Debian amavisd-new at bastet.se.axis.com
Received: from bastet.se.axis.com ([IPv6:::ffff:127.0.0.1])
	by localhost (bastet.se.axis.com [::ffff:127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id 6LYXU_Ak-IRA; Thu,  7 Mar 2019 15:17:30 +0100 (CET)
Received: from boulder02.se.axis.com (boulder02.se.axis.com [10.0.8.16])
	by bastet.se.axis.com (Postfix) with ESMTPS id 28C8F185B8;
	Thu,  7 Mar 2019 15:17:30 +0100 (CET)
Received: from boulder02.se.axis.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EFCA81A06D;
	Thu,  7 Mar 2019 15:17:29 +0100 (CET)
Received: from boulder02.se.axis.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E453D1A061;
	Thu,  7 Mar 2019 15:17:29 +0100 (CET)
Received: from seth.se.axis.com (unknown [10.0.2.172])
	by boulder02.se.axis.com (Postfix) with ESMTP;
	Thu,  7 Mar 2019 15:17:29 +0100 (CET)
Received: from XBOX04.axis.com (xbox04.axis.com [10.0.5.18])
	by seth.se.axis.com (Postfix) with ESMTP id D86E92AE6;
	Thu,  7 Mar 2019 15:17:29 +0100 (CET)
Received: from [10.88.41.2] (10.0.5.60) by XBOX04.axis.com (10.0.5.18) with
 Microsoft SMTP Server (TLS) id 15.0.1365.1; Thu, 7 Mar 2019 15:17:29 +0100
Subject: Re: [PATCH] mm: migrate: add missing flush_dcache_page for non-mapped
 page migrate
From: Lars Persson <lars.persson@axis.com>
To: Vlastimil Babka <vbabka@suse.cz>, Lars Persson <larper@axis.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
CC: <linux-mips@vger.kernel.org>
References: <20190219123212.29838-1-larper@axis.com>
 <65ed6463-b61f-81ff-4fcc-27f4071a28da@suse.cz>
 <ed4dd065-5e1b-dc20-2778-6d0a727914a8@axis.com>
 <2de280a9-e82a-876c-e13b-a2e48d89700a@suse.cz>
 <24af691e-03ab-d79a-ddbd-7057dcf46826@axis.com>
Message-ID: <237ecd2f-477f-2dc7-7849-643e47fe56d5@axis.com>
Date: Thu, 7 Mar 2019 15:17:24 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <24af691e-03ab-d79a-ddbd-7057dcf46826@axis.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: sv
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: XBOX04.axis.com (10.0.5.18) To XBOX04.axis.com (10.0.5.18)
X-TM-AS-GCONF: 00
X-Bogosity: Ham, tests=bogofilter, spamicity=0.303086, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/26/19 12:57 PM, Lars Persson wrote:
> 
> 
> On 2/26/19 11:07 AM, Vlastimil Babka wrote:
>> On 2/26/19 9:40 AM, Lars Persson wrote:
>>>> What about CC stable and a Fixes tag, would it be applicable here?
>>>>
>>>
>>> Yes this is candidate for stable so let's add:
>>> Cc: <stable@vger.kernel.org>
>>>
>>> I do not find a good candidate for a Fixes tag.
>>
>> How bout a version range where the bug needs to be fixed then?
>>
> 
> The distinction between mapped and non-mapped old page was introduced in 2ebba6b7e1d9 ("mm: unmapped page migration avoid unmap+remap overhead") so at least it applies to stable 4.4+.
> 
> Before that patch there was always a call to remove_migration_ptes() but I cannot conclude if those earlier versions actually will reach the flush_dcache_page call if the old page was unmapped.
> 

Should I submit a V2 patch with CC stable for v4.4+ ?

- Lars


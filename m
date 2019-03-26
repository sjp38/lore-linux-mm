Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E2E5C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 20:11:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D59012070D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 20:11:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="FZsDoNRb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D59012070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A0A26B0003; Tue, 26 Mar 2019 16:11:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22A7D6B0005; Tue, 26 Mar 2019 16:11:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F3A16B0006; Tue, 26 Mar 2019 16:11:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C774C6B0003
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 16:11:33 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s22so2811011plq.1
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 13:11:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=culWY/Rk+vffcRaES9PIUDEE10WbDjvCzyyOH86GQbI=;
        b=iwNGarwhTI0KiqXrTLGmQtPVc9V3uWtLfW23uAnn/nMRQsJT9SW+iipb+MUypWgSQp
         YSNtp+s2m+vfsEhbeXKnjH6c0+Aggr37w1lDnmI+L/c/hzvl8Ke+kRUHwPT26LrKBPtX
         UHZbUYybqPBCXQKArvMi+R9Re5UuxVp2KEBqLpNATdAxL4wjzGTU9UtdX8JbWAUubfWn
         X7KMHtsYZcamqjlXH8YQMA2611d0zqzh1gTiifBUXWKHrbMJetBaSKal/hhe81nWfxiw
         1tyZ00KLJ+GVQROPQIo+nHs+NGrKjpL6Iy9nMKMJn8hBTxpmlM2gJwQ1ucolcAIZOv2y
         USpg==
X-Gm-Message-State: APjAAAUnj45DS+8NtfpUAoDGEYX1f4evyp570ogfsCN1Tig7GpAgDZTV
	mrMQcr/eRmCnHpwOSBeMRgIOetPfBj/6qeXB9ILGPbKyWlcjTWzl8Gf4SPTQZxIEyrA/PWdpJmA
	IKuVV8CYAoPeKjqlw2qx6/gQVXY0mIEEsZhi2ITCfcAS+pYb0d58A816dYDRQdBnIdA==
X-Received: by 2002:a62:a509:: with SMTP id v9mr32504038pfm.64.1553631093459;
        Tue, 26 Mar 2019 13:11:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjyHoughIOb5xDCEOWaNlcdcxL93hddcpUjFG4XWWDU1V4HA39srzSyVpmPFynsESS1SHS
X-Received: by 2002:a62:a509:: with SMTP id v9mr32503973pfm.64.1553631092595;
        Tue, 26 Mar 2019 13:11:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553631092; cv=none;
        d=google.com; s=arc-20160816;
        b=LvjX5klJgkX/g42Or2axjk6zfr6IPH0Yo5pZ7TE3AV6ZoFmc6YMpvtzvc3IL1GS2CH
         q1v6oVzKtjN3+00O9hy+U743d5Yd2qRENZE+6ZnjXsFyEFaGhOkkYmKaMBBTTqoGuyh+
         FjD11CbFg+7syhB8nH8cjB8qgcrGDU9d/4B18nwwNaZOjknskzcse7Qmny6BdiBfP3dk
         AMANlfo9Dn1f8YYvwhRcvx0nwhbfaPSkPP3K7OJGLHtFVOxRTP09cv6t12Tj2gHCn/wI
         crTb8WuLQQ50epxdrIFd1RECzLgUGAVmQsPDBQmMAKGPS/DyikUz1dOyP4+YUoWEvnUn
         t2Jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=culWY/Rk+vffcRaES9PIUDEE10WbDjvCzyyOH86GQbI=;
        b=VhoLZSIXqnpeqGIzy/SURIcJVQ0YjP+mTFxbdW5gy3gfeb9jrlAe4prOAd6avue78J
         TQ+VuxmuzHCnSax4VZ/SKUH0jWZC970jFiCvkqs15otHQlMI+MKGNfRs5WVtpeOKms4i
         KOK4z6YrLDNVMw3Atwi+u37Im209NmShVyriHBmjrBeqdtkyTCEitkb+dufA1wzyy+vt
         HKuff0FJR4QN4MDVET8cBbqYxbSnHAbEN6QmXaAa/otb2KxK8Nl9ZcCllVnXwxDlQx72
         +WUCkiE3Q1Rb4keXkajQUmb5jmdtW7iVGr1KWvrfHoS9TXmF5w/0+1hjMWVSszJC7LOX
         uM0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FZsDoNRb;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id y2si17072727pll.133.2019.03.26.13.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 13:11:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FZsDoNRb;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9a876f0000>; Tue, 26 Mar 2019 13:11:27 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 26 Mar 2019 13:11:31 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 26 Mar 2019 13:11:31 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 26 Mar
 2019 20:11:31 +0000
Subject: Re: CONFIG_DEBUG_VIRTUAL breaks boot on x86-32
To: William Kucharski <william.kucharski@oracle.com>, Meelis Roos
	<mroos@linux.ee>
CC: LKML <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
References: <4d5ee3b0-6d47-a8df-a6b3-54b0fba66ed7@linux.ee>
 <A1B7F481-4BF6-4441-8019-AE088F8A8939@oracle.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <f39477da-a1ef-e31e-a72d-8ea1d5755234@nvidia.com>
Date: Tue, 26 Mar 2019 13:11:31 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <A1B7F481-4BF6-4441-8019-AE088F8A8939@oracle.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553631087; bh=culWY/Rk+vffcRaES9PIUDEE10WbDjvCzyyOH86GQbI=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=FZsDoNRbAc/4HIAqnX+Vhp3z8GG7gJK9XpzbJ0o2AgUmo77iMdqmeGf4hsqJirXFz
	 KD9YQx8cyDZO2zOa5KWXzLwhqJrh9hJBmbOral0aoQpkDeXzt0B4yZmiPBrBnFDpTp
	 TnBXlS8XB16psg0eMYJrReNvKrHk6g9aM/ARYSLDwVek7HIhpN97BE635DArVyfjQp
	 WFVjSAb0n+pK7VZWXuU0w31wIiDT1wdFIQNJDcS53JFHb9WI3LujqgV1CRBoqOM7Oq
	 JzBMHcvXLsGogWedfKMpP8GzGvjLl6TmCN5uCvZ/aUTFacBwemf5G75ZNiWaQUxG5I
	 5a14bPxDCOjPA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/26/19 6:52 AM, William Kucharski wrote:
> Does this still happen on 5.1-rc2?
> 
> Do you have idea as to what max_low_pfn() gets set to on your system at boot time?
> 
>  From the screen shot I'm guessing it MIGHT be 0x373fe, but it's hard to know for sure.
> 
> 
>> On Mar 21, 2019, at 2:22 PM, Meelis Roos <mroos@linux.ee> wrote:
>>
>> I tried to debug another problem and turned on most debug options for memory.
>> The resulting kernel failed to boot.
>>
>> Bisecting the configurations led to CONFIG_DEBUG_VIRTUAL - if I turned it on
>> in addition to some other debug options, the machine crashed with
>>
>> kernel BUG at arch/x86/mm/physaddr.c:79!
>>
>> Screenshot at http://kodu.ut.ee/~mroos/debug_virtual-boot-hang-1.jpg
>>
>> The machine was Athlon XP with VIA KT600 chipset and 2G RAM.
>>
>> -- 
>> Meelis Roos <mroos@linux.ee>
>>
> 

You might be hitting a bug I found.
Try applying this patch:
https://marc.info/?l=linux-kernel&m=155355953012985&w=2


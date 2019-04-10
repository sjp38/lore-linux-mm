Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C1E0C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:09:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18A7321B1A
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 11:09:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18A7321B1A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amlogic.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B69526B028B; Wed, 10 Apr 2019 07:09:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B19796B028C; Wed, 10 Apr 2019 07:09:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BB646B028D; Wed, 10 Apr 2019 07:09:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 786106B028B
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 07:09:17 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id r186so1781578ita.7
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:09:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ENWe0N+vf6bh4a26hfBJeNClgOvwuyrVo0Una9cblCU=;
        b=YTacSzj99+FZMCL0uyaX1k79Iv76py+Eop6s6jBOqjYj/oazpZa6ihtKbrTPu3qAfp
         F9jS+Em2WB8f+mqX0zoRZ516rPW13YLsDEwCFS92rb5RJPdhJntv1KwQYYU5rwsU04in
         4O45ZkKlSznb2lNUO3nnF3sNy3bvvGPXj84eHYVvqwfNDpzZq/36zecdgUiY9cVHKRi+
         qdP4+qwKC0NdWOE84byhlWgH1J++luYZoL4HzM9WqlktcLQbZBhAdSHqL/I9erja9rEs
         1ftmpChqTVXnij67jVNx7beKNN86MtvD5n/gJ+NCWFPJfTIXhJCbMqrdlg6y9ZZTarDp
         4e9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) smtp.mailfrom=Liang.Yang@amlogic.com
X-Gm-Message-State: APjAAAVpp0CnY1zWentJ0IbAb9RweK4yY0jwXdm6R9StYLtG40eoFFbK
	HvHxU4XlV1uS+kMZ1NAOkcrtJKLyvHVPaFbTzPyiItVcslFuJ30YXBFhYJOEFMwD/MLqxu0T9tk
	LcElh6um6ONX0cpIt/ehMtjF4GHnTkHgNEqaChwvvmRdRsBpfxQEXNPRPeFUwtHTnSA==
X-Received: by 2002:a02:c4c2:: with SMTP id h2mr30440997jaj.86.1554894557240;
        Wed, 10 Apr 2019 04:09:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNLC8oEpRA6TCJ0I3yCV3hg2xc2CYnMLtvTLu8FfqPiUIbIeKRm6Ex27egUw7xyHszbDc2
X-Received: by 2002:a02:c4c2:: with SMTP id h2mr30440912jaj.86.1554894556023;
        Wed, 10 Apr 2019 04:09:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554894556; cv=none;
        d=google.com; s=arc-20160816;
        b=PhVoMv3uDNcGbOaMLTXErmA311pPNwqN8J+WU3bGxVJYdJ/p2LBHVo2S8DZwx6IfvI
         r00mzG2+URyMT8u6ctNw6Zhp8hjxGRUgydcOW3FfDivi87CxRry1qOu6QPsKFBOOwMYZ
         LbJih0CxMvIU/QUAi+67NkHb+pv96TLZ7ADcNlcvXiPvO3LSAqxRKgUHADenZgJx+XkH
         On/wH+t8d7jWPCh2sCxX710qit4fy1eRQXkB4tz8Oo9Jk7HQak5Wkw+qB79d6lUERtBR
         zzuwRq96il9eYj6Gx/X+Nj0VBzuBElMNYdG2680ufBfVX4JVBwRGafEUBosl/RPpKvec
         YLlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ENWe0N+vf6bh4a26hfBJeNClgOvwuyrVo0Una9cblCU=;
        b=CEafA8sRYzALTxS9e64BNAyAhvvLP4GGsrrBMBF5bfLTDyQXYGhOmnxqKWg01E5qbM
         fxAyXAh8LGrhHvBu1UJFq8DaLsODUyWjHntd7omhpBw5WyLJRK69rkAoj/tilBnr4MQH
         yXQ2ST+gKYOzdPjZxthNYfUhl/W0JLZeUk4Jd4511IF4NGesgKrdV8ldMnwEMxS9dcQR
         Ul9Sh/Dzy7rgrsBWdpPpykTdpP7R74oEC/aro4XDwF5orfOaXirYA71CFWwGvnzwINEi
         XhBbZ/RSsbufbv+M9vvZ6OKS6t0AIiydh7M6k/mcHjIq5P5yuDPgKC8BC3DdNkbdmsJI
         OQtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) smtp.mailfrom=Liang.Yang@amlogic.com
Received: from mail-sz.amlogic.com (mail-sz.amlogic.com. [211.162.65.117])
        by mx.google.com with ESMTPS id g204si12138658jac.38.2019.04.10.04.09.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 04:09:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) client-ip=211.162.65.117;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) smtp.mailfrom=Liang.Yang@amlogic.com
Received: from [10.28.18.125] (10.28.18.125) by mail-sz.amlogic.com
 (10.28.11.5) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1591.10; Wed, 10 Apr
 2019 19:08:17 +0800
Subject: Re: 32-bit Amlogic (ARM) SoC: kernel BUG in kfree()
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
CC: Matthew Wilcox <willy@infradead.org>, <mhocko@suse.com>,
	<linux@armlinux.org.uk>, <linux-kernel@vger.kernel.org>,
	<rppt@linux.ibm.com>, <linux-mm@kvack.org>, <linux-mtd@lists.infradead.org>,
	<linux-amlogic@lists.infradead.org>, <akpm@linux-foundation.org>,
	<linux-arm-kernel@lists.infradead.org>
References: <CAFBinCBOX8HyY-UocsVQvsnTr4XWXyE9oU+f2xhO1=JU0i_9ow@mail.gmail.com>
 <20190321214401.GC19508@bombadil.infradead.org>
 <CAFBinCA6oK5UhDAt9kva5qRisxr2gxMF26AMK8vC4b1DN5RXrw@mail.gmail.com>
 <5cad2529-8776-687e-58d0-4fb9e2ec59b1@amlogic.com>
 <CAFBinCA=0XSSVmzfTgb4eSiVFr=XRHqLOVFGyK0++XRty6VjnQ@mail.gmail.com>
 <32799846-b8f0-758f-32eb-a9ce435e0b79@amlogic.com>
 <CAFBinCDHmuNZxuDf3pe2ij6m8aX2fho7L+B9ZMaMOo28tPZ62Q@mail.gmail.com>
 <79b81748-8508-414f-c08a-c99cb4ae4b2a@amlogic.com>
 <CAFBinCCSkVGp_iWKf=o=7UGuDUWxyLPGdrqGy_P-HPuEJiU1zQ@mail.gmail.com>
From: Liang Yang <liang.yang@amlogic.com>
Message-ID: <8cb108ff-7a72-6db4-660d-33880fcee08a@amlogic.com>
Date: Wed, 10 Apr 2019 19:08:17 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAFBinCCSkVGp_iWKf=o=7UGuDUWxyLPGdrqGy_P-HPuEJiU1zQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.28.18.125]
X-ClientProxiedBy: mail-sz.amlogic.com (10.28.11.5) To mail-sz.amlogic.com
 (10.28.11.5)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Martin,

On 2019/4/5 12:30, Martin Blumenstingl wrote:
> Hi Liang,
> 
> On Fri, Mar 29, 2019 at 8:44 AM Liang Yang <liang.yang@amlogic.com> wrote:
>>
>> Hi Martin,
>>
>> On 2019/3/29 2:03, Martin Blumenstingl wrote:
>>> Hi Liang,
>> [......]
>>>> I don't think it is caused by a different NAND type, but i have followed
>>>> the some test on my GXL platform. we can see the result from the
>>>> attachment. By the way, i don't find any information about this on meson
>>>> NFC datasheet, so i will ask our VLSI.
>>>> Martin, May you reproduce it with the new patch on meson8b platform ? I
>>>> need a more clear and easier compared log like gxl.txt. Thanks.
>>> your gxl.txt is great, finally I can also compare my own results with
>>> something that works for you!
>>> in my results (see attachment) the "DATA_IN  [256 B, force 8-bit]"
>>> instructions result in a different info buffer output.
>>> does this make any sense to you?
>>>
>> I have asked our VLSI designer for explanation or simulation result by
>> an e-mail. Thanks.
> do you have any update on this?
> Sorry. I haven't got reply from VLSI designer yet. We tried to improve 
priority yesterday, but i still can't estimate the time. There is no 
document or change list showing the difference between m8/b and gxl/axg 
serial chips. Now it seems that we can't use command NFC_CMD_N2M on nand 
initialization for m8/b chips and use *read byte from NFC fifo register* 
instead.
> 
> Martin
> 
> .
> 


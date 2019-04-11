Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67DECC10F11
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:01:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 234CB20818
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:01:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 234CB20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amlogic.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B10386B0005; Wed, 10 Apr 2019 23:01:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABFFE6B0006; Wed, 10 Apr 2019 23:01:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9617B6B0007; Wed, 10 Apr 2019 23:01:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE276B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 23:01:12 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g37so3445004pgl.19
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 20:01:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=wKbEi4a976AQiJ9g7gaLXqKOCVB5a1RcsK8dk0/11LM=;
        b=offHPbqLmPYWIx/V7AMeA54qKwYS5AAn9onlWxaA1WTP/EtDWooEyE5ZILD6O7fEau
         L9Md0XwcPJO7Oi1D8Vv9dGnFvfTq+QHAunaJnRO4BYsx67VpaYxx3BDA+rTYMhrdjJ4W
         3xTqFgetSKzjLrNsGjybfYdb01HDgvYDl/XSDtYuP6ooMnRodAWLci5cQr/WXryaKbPM
         uYVOTN/cXkM4UbDGKGMZWzYwCS8bmnc+ORlcZRFRVUi/I5vZlCIMeU4iq3T5MrXtwh80
         6x/tcmXcj9cp2mIJFcaEtz7xWq8fpc5wXQU4t099cjG/5Eotpw28HvMCJJeY48BC3qDp
         7O8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) smtp.mailfrom=Liang.Yang@amlogic.com
X-Gm-Message-State: APjAAAWU2jhFSKsa60cZMTJ79ayswrebyCphhLSGDMxzK0lEfiU9LAZv
	ytJ9GzkWYikbmLhcRiRE7Set/PoH6+h718V7msXLriaO5Lv7YRFFutiicx0kH2Ws4N1p0xlhZFY
	JHTD32eB74iTVv/Kv6qMADVfnyDJVwE+ollTHy2CeeiCZSEJKfMr5Kgwkq8tE79z5cQ==
X-Received: by 2002:a62:1318:: with SMTP id b24mr46709759pfj.201.1554951671807;
        Wed, 10 Apr 2019 20:01:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuvLfDfLqsSH3yRcj57CsqxGzvbh++w6EkQJ6PDh85uKWcBJXoQ+oAM38JMlXOx/e9ne8h
X-Received: by 2002:a62:1318:: with SMTP id b24mr46709689pfj.201.1554951670855;
        Wed, 10 Apr 2019 20:01:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554951670; cv=none;
        d=google.com; s=arc-20160816;
        b=H6zxqYi+P5gAdlAmjtfBr4TgsFYx4bSLd9Cv4ibXL6f6hTMD3ZScaI79lE2X7cxogL
         3T7HUIZsDmUWo5EfeJu7JXtP/KwPtojM/9flH8Uzhn8H1p9TcIGG8Z985Xl1IiZYJ87v
         VQ+jmPQuInVc+tBj9RblmnDrgeYmQBwJ2dKAz+sngI6DpfjwCoGDgIhcQjEmghPhUI/K
         TjRVjB65g/G/vrAJMUfBvNbMNGd+LUHxRc6gSW7kz/4e6Y3evwoncr86dMQL8LlwN0fI
         W/n+yp+Ok3uaIGjZWDW9lD7hS12IELFLPFk3gKSeBfpypSHxbTLJECPDrucFwe4h7lms
         BjYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=wKbEi4a976AQiJ9g7gaLXqKOCVB5a1RcsK8dk0/11LM=;
        b=Mp5L9R4TbET8Q9zbySvho6c4JvTmo779UqjYLqkp+4CEaxrp8dWV0ql2k2JpqDZcrV
         HnU4b5HzV5DPFu6GSP9zzM1+pLGKgS9j+5LqDpG4OWYlixoBQMCT+OlOSyR52jc52MJm
         5BG+nNMgaLJVNRz+rDGINdmhJhL4qSIPhD4t749x+8knV8OBXQS6eUTUEY5Q/+nfT9Nx
         XG79AXT7ZikDrBJ052TbA1KjAohFZymyEPySG4shywRGsCCZrS9EWJym3TEQmxbvf9sU
         gdwHNpnUSfdLPpaEfmhbwWTqlQt6rBqLQeAMR0/X2vc4ZyK18DQHYWGLKaXPagQoSy4u
         O70A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) smtp.mailfrom=Liang.Yang@amlogic.com
Received: from mail-sz.amlogic.com (mail-sz.amlogic.com. [211.162.65.117])
        by mx.google.com with ESMTPS id j1si8110780pfc.194.2019.04.10.20.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 20:01:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) client-ip=211.162.65.117;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) smtp.mailfrom=Liang.Yang@amlogic.com
Received: from [10.28.18.125] (10.28.18.125) by mail-sz.amlogic.com
 (10.28.11.5) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1591.10; Thu, 11 Apr
 2019 11:00:30 +0800
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
 <8cb108ff-7a72-6db4-660d-33880fcee08a@amlogic.com>
 <CAFBinCD4cRGbC=cFYEGVAHOtBSvrgNbCSfDWe3To0KCE5+ceVw@mail.gmail.com>
From: Liang Yang <liang.yang@amlogic.com>
Message-ID: <45ce172c-5c76-bb69-31c8-af91e8ffdd68@amlogic.com>
Date: Thu, 11 Apr 2019 11:00:31 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAFBinCD4cRGbC=cFYEGVAHOtBSvrgNbCSfDWe3To0KCE5+ceVw@mail.gmail.com>
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
On 2019/4/11 1:54, Martin Blumenstingl wrote:
> Hi Liang,
> 
> On Wed, Apr 10, 2019 at 1:08 PM Liang Yang <liang.yang@amlogic.com> wrote:
>>
>> Hi Martin,
>>
>> On 2019/4/5 12:30, Martin Blumenstingl wrote:
>>> Hi Liang,
>>>
>>> On Fri, Mar 29, 2019 at 8:44 AM Liang Yang <liang.yang@amlogic.com> wrote:
>>>>
>>>> Hi Martin,
>>>>
>>>> On 2019/3/29 2:03, Martin Blumenstingl wrote:
>>>>> Hi Liang,
>>>> [......]
>>>>>> I don't think it is caused by a different NAND type, but i have followed
>>>>>> the some test on my GXL platform. we can see the result from the
>>>>>> attachment. By the way, i don't find any information about this on meson
>>>>>> NFC datasheet, so i will ask our VLSI.
>>>>>> Martin, May you reproduce it with the new patch on meson8b platform ? I
>>>>>> need a more clear and easier compared log like gxl.txt. Thanks.
>>>>> your gxl.txt is great, finally I can also compare my own results with
>>>>> something that works for you!
>>>>> in my results (see attachment) the "DATA_IN  [256 B, force 8-bit]"
>>>>> instructions result in a different info buffer output.
>>>>> does this make any sense to you?
>>>>>
>>>> I have asked our VLSI designer for explanation or simulation result by
>>>> an e-mail. Thanks.
>>> do you have any update on this?
>> Sorry. I haven't got reply from VLSI designer yet. We tried to improve
>> priority yesterday, but i still can't estimate the time. There is no
>> document or change list showing the difference between m8/b and gxl/axg
>> serial chips. Now it seems that we can't use command NFC_CMD_N2M on nand
>> initialization for m8/b chips and use *read byte from NFC fifo register*
>> instead.
> thank you for the status update!
> 
> I am trying to understand your suggestion not to use NFC_CMD_N2M:
> the documentation (public S922X datasheet from Hardkernel: [0]) states
> that P_NAND_BUF (NFC_REG_BUF in the meson_nand driver) can hold up to
> four bytes of data. is this the "read byte from NFC FIFO register" you
> mentioned?
> 
You are right.take the early meson NFC driver V2 on previous mail as a 
reference.

> Before I spend time changing the code to use the FIFO register I would
> like to wait for an answer from your VLSI designer.
> Setting the "correct" info buffer length for NFC_CMD_N2M on the 32-bit
> SoCs seems like an easier solution compared to switching to the FIFO
> register. Keeping NFC_CMD_N2M on the 32-bit SoCs also allows us to
> have only one code-path for 32 and 64 bit SoCs, meaning we don't have
> to maintain two separate code-paths for basically the same
> functionality (assuming that NFC_CMD_N2M is not completely broken on
> the 32-bit SoCs, we just don't know how to use it yet).
> 
All right. I am also waiting for the answer.
> 
> Regards
> Martin
> 
> 
> [0] https://dn.odroid.com/S922X/ODROID-N2/Datasheet/S922X_Public_Datasheet_V0.2.pdf
> 
> .
> 


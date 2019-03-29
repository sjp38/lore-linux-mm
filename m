Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D68B1C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 07:44:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E8EC2173C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 07:44:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E8EC2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amlogic.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C3186B0007; Fri, 29 Mar 2019 03:44:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 370986B0008; Fri, 29 Mar 2019 03:44:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2603B6B000C; Fri, 29 Mar 2019 03:44:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 005746B0007
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 03:44:13 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id m128so112391itm.6
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 00:44:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=fruQuhXDJOkN2YO9WuiFEwibPfnajNRWGslfzNs3T74=;
        b=kf0B2/TRTZZvyGgA7sAVPn3acuatGFzORpOTmhLc4a56ISi3lK3LkpYLJ9YfxoEMG7
         +dN4+VSSNOZN7kVOlaaEaTFnLP8IV06wbYEM8Ew8uK9K4RRA7C2+t5gDm8bL7IlwlDRb
         gpbuGz6grac1WOsy+1kIM8YgsnZewyVuu42oeLWV1kFH3W1Vk3m7CPh6CMjTz/8oaoG7
         J6I7l3L92ndX9XeuoXs+db2ktCu26BzanO8DbKgfaN6L4Z4Vx3ng4dsSQnvoPgZAtUN9
         Xm6VcXd+fbRsdzA5yjN9n9WfLmDGoCv9Dqh2a1rKobDpaU+gZp56gcI1SKJyARHzLcam
         TFMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) smtp.mailfrom=Liang.Yang@amlogic.com
X-Gm-Message-State: APjAAAUjXSVpJmO8GMeMCdTPXETkP3wQ79th3xgCK+OzX3x/CmFiIKvq
	9l9hQdYFb+/G1GCY7kS5MkeDNYH2aWurZS9tSIpRknyb4l2csQf/QJTr2WGGg8C4pNxgWreo/6u
	Btyffuw8LTaiKQrz3l3nCPQM+wfDll0wzQ4lESZAVlXCnSBotZUIWNtom1ZqI8QqoVw==
X-Received: by 2002:a24:c106:: with SMTP id e6mr3362172itg.21.1553845453662;
        Fri, 29 Mar 2019 00:44:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUlrlSVTxWvUGxOQHkqHMbS+bewINSh4LJug8xj2J9S0/4uvKieXqK2n0vQF4WNhja7TzO
X-Received: by 2002:a24:c106:: with SMTP id e6mr3362136itg.21.1553845452804;
        Fri, 29 Mar 2019 00:44:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553845452; cv=none;
        d=google.com; s=arc-20160816;
        b=ACcn9ROMsAXXU7iNtjnICn3xBlOYUSVVSfEhQFUNmg8NtC793tiU8/nzDGfB7oqTu7
         YajkS6T0X1xXNJMa9QMjkgB2Yu2O55VmK8qVe4OB8lHQHcLCz5/3pSvPBiBzmga8dzjr
         ogMnnBL5PExYAKevzr35OrO5jKazARU0rm2lExj0A9nvFg42XsKE/EhVnNqkLDca0ExW
         IQsfq56urFOvNRZXTgefiQDmWp3hmyWI1OBaixZmssiv9kyTUfM2SrRyFZ5RQpeI89yv
         ph6GWAGKtKm2ziclFVrZPah4ik4KbYvMxKY65EqGn8dK+k31X+iUoZPGJoqCAfnqOlYH
         LMVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=fruQuhXDJOkN2YO9WuiFEwibPfnajNRWGslfzNs3T74=;
        b=dKELaQ0JVtsBpn+Xw2SVQOOboBgNM5+kwx+Cv/BxNcrRe57QbWCUuemc5Z6JwIZJ/K
         Y2bzqqMrrTn01Nip3x3F+9lmyGOOgESoXXwXp9+luhP0qpveBZi0tlE/8TvlRwbGSnC+
         QFaR8pMwKUHMap24ulKuCWZig4bBCqedbh8+8hNYqW8u3JLZNHSRGDqJ2f1ePi6q6Z9U
         kZf1JNUKS8Ib5+TTpFLoSGMfnUo4wzSCIrUBON891Iv2bNyNWP24+Yauk5FG9g3DDJyS
         8Uf7MY8+5oWf4pw70daoLJj99vfmK54zb0VCcC+I3VsFQ/bFO3lBYR+S3lIt5J/PTnSY
         D5VA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) smtp.mailfrom=Liang.Yang@amlogic.com
Received: from mail-sz.amlogic.com (mail-sz.amlogic.com. [211.162.65.117])
        by mx.google.com with ESMTPS id k35si666299jac.85.2019.03.29.00.44.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 00:44:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) client-ip=211.162.65.117;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liang.yang@amlogic.com designates 211.162.65.117 as permitted sender) smtp.mailfrom=Liang.Yang@amlogic.com
Received: from [10.28.18.125] (10.28.18.125) by mail-sz.amlogic.com
 (10.28.11.5) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1591.10; Fri, 29 Mar
 2019 15:44:30 +0800
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
From: Liang Yang <liang.yang@amlogic.com>
Message-ID: <79b81748-8508-414f-c08a-c99cb4ae4b2a@amlogic.com>
Date: Fri, 29 Mar 2019 15:44:30 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <CAFBinCDHmuNZxuDf3pe2ij6m8aX2fho7L+B9ZMaMOo28tPZ62Q@mail.gmail.com>
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

On 2019/3/29 2:03, Martin Blumenstingl wrote:
> Hi Liang, 
[......]
>> I don't think it is caused by a different NAND type, but i have followed
>> the some test on my GXL platform. we can see the result from the
>> attachment. By the way, i don't find any information about this on meson
>> NFC datasheet, so i will ask our VLSI.
>> Martin, May you reproduce it with the new patch on meson8b platform ? I
>> need a more clear and easier compared log like gxl.txt. Thanks.
> your gxl.txt is great, finally I can also compare my own results with
> something that works for you!
> in my results (see attachment) the "DATA_IN  [256 B, force 8-bit]"
> instructions result in a different info buffer output.
> does this make any sense to you?
> 
I have asked our VLSI designer for explanation or simulation result by 
an e-mail. Thanks.


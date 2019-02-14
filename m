Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A54B8C10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 23:10:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 623B421B1A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 23:10:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B80IEHWH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 623B421B1A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C28888E0002; Thu, 14 Feb 2019 18:10:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD77E8E0001; Thu, 14 Feb 2019 18:10:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC6B08E0002; Thu, 14 Feb 2019 18:10:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58F6F8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:10:40 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id f4so2929602wrg.9
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 15:10:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=z+9zbb8RFe/yUhMkwO8O4v64fl479cQbUFQDaaeTxkI=;
        b=Z8230yoCyxSAiNrsKueYImDGkQ72uzfHh1FaWgcyvoIXx6Pu2eV0Zhc+QF/ZHh1loP
         p2IL52L5qUX+vDInySFF+C1rp6ECP79LsRsh77KbKYKGCfkMmTcBl9ksTUejyV3ugQ6e
         YRJiUoNsBmyQhLbl/TrBxDL8IHT4Ii3inAWtJS3JYLSNNulcT9a/lyuLtho3OtEp0JGQ
         Og24rBNaZ2UB3/13Hm6aFxScusTkLkzdIm4TTIjHagdHZM1tosj3QKyU/GQivb3jwBR1
         PgN6jM054DjNQsjQIzVTcDISnOVbcsRjQP0wzmXcrJyieXZyAJaKLbUYn4kmqfV6GSKC
         0HiQ==
X-Gm-Message-State: AHQUAuZAuk+VHpY7siThVEq6nRbBBEDDA7iyUdyP6haoaqS8L49WSbbh
	Di+ECJ++knmeX5lkHlRZhHk6cs6d99DJYI8cxlVSPUAMa5kSiMoCn1X2MZNSWXau3cNgJNG4WRN
	78PqJo8ptceBiPhmbROV9rZiErcn/Jerfv+C020LMFwUD1us0sYA8q1fJ/liXSkNfQyQUhWfn8j
	wKUoBSfvqKZVZxJ3fR1nmUeP5xdEPTDlxzteDooPLrVk6ek55BmQmM6RcB3Ae6OtIDKL52j6moV
	1nBgEo7ZnA8DK9e7vBFyGASxoLfbWVbdGJezOgUQeO7tCQAhxQ4q0MB6SCPRwouSKaVbZDFN4Sm
	2TmehSkwdojLVPy0EMW7wDlPoFn78e5OR4MBjZZ+LLKM7NWRPYFQh9a8EEswhmoaJgYgoo99pB+
	N
X-Received: by 2002:a05:600c:2102:: with SMTP id u2mr4424170wml.152.1550185839729;
        Thu, 14 Feb 2019 15:10:39 -0800 (PST)
X-Received: by 2002:a05:600c:2102:: with SMTP id u2mr4424131wml.152.1550185838650;
        Thu, 14 Feb 2019 15:10:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550185838; cv=none;
        d=google.com; s=arc-20160816;
        b=TG3u93uZJc//lN4VVBFkqgWqiji29rW39cLOB3MI8V2RGAuxRIRGpfpyfSIAlXsSvX
         G/zYM+rhk5syDkKCN6lfZVxE0Xd2+6mssgVcJg4mGSgZo+Vs+j+EeiwljIs3xFA007rs
         z8UzkJgTcXnZ4o6h331e9U8b336fceeu9AtiAZu1kTaK19MOOECZoMLLQyxyIUPaLboS
         k6/hv5YbEMVk3fxyuKcFOFXij7f3xEtZ1GpiB8dJQlrCx4UAfgWk+oMUcqSulXNr30vu
         agd7TsNCoosQzbRN3dBcDqAhZb5yZR5dDIoJhxgfqOyOUshxiIzj6nB3joM//FOmsvxr
         nHxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=z+9zbb8RFe/yUhMkwO8O4v64fl479cQbUFQDaaeTxkI=;
        b=WGEDr+VjvWSVOjAAXIIPM3r5HHZZupdeUoMsxsqFjYgNpeL+dqe5A+s3hwMRZm0Kyo
         WaWNCtpp7AJXz1ch9ysKyUA2U+/3rNFROnwNBkanK71uelY9cxzWlElZP6MBfHyCfvkf
         43qyJEgaa5opV4Bynxuxi8OTCq5mZlaBw4wJ6+EGGqB0axG57kwwYXFdsG++cwAfiRA5
         vfjrHJrwpJgY0BvO2Ep69loRfWGWs7Cf0lGBN7oBXJtxjQ80PFDIsKz9Vnj+H9hEAH9O
         yiVFIVjuoiXMjN4WBkPj9nNMU0RLfLAi4I564r9ojMqwMjFyqCRefwZKeAAsbxqPb+UI
         tXMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=B80IEHWH;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10sor2784735wro.1.2019.02.14.15.10.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 15:10:38 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=B80IEHWH;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=z+9zbb8RFe/yUhMkwO8O4v64fl479cQbUFQDaaeTxkI=;
        b=B80IEHWH7Opk+JI5pSyBN4WBwwOYdiaWFl5lpRa56dKMWQrdo0SWI013F9SnWvp4RU
         a4xLPNKiVu07GJ1V7SYGutQTTXfzXuy7JpPMaCZ24/2Op1XfDcdkxZMRzHfbqAFjrFpw
         SklayuQMtbEtVR/7bOqkXTvN+qe9TiN5iOahznxESvMsLUm642K93wv2CyS9BvegFx3U
         OcRMfZEkQjDQChQB7YhbPScjb1bLjsnQwEK6iCk0M5fNlDU7nKcz6EAWOWf7Dfc/kvwJ
         C1wGcbVsMUIqUMzWqKgK8CRMX8WJzStgIy0HvBfie3isr4IJbfeSWGGtGaQnric/khNQ
         LrMg==
X-Google-Smtp-Source: AHgI3IbsNlk4Fvpr3HH+kDs+qGc4Q1NAHmTiRsxdrVOqxRzBB2FRVhft3utppOvMD+0T6z/BkkeXbA==
X-Received: by 2002:adf:e949:: with SMTP id m9mr4830622wrn.1.1550185838039;
        Thu, 14 Feb 2019 15:10:38 -0800 (PST)
Received: from [10.32.107.126] ([80.227.69.14])
        by smtp.gmail.com with ESMTPSA id o12sm10467992wre.0.2019.02.14.15.10.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 15:10:37 -0800 (PST)
Subject: Re: [RFC PATCH v5 03/12] __wr_after_init: Core and default arch
To: Peter Zijlstra <peterz@infradead.org>
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
 Andy Lutomirski <luto@amacapital.net>, Nadav Amit <nadav.amit@gmail.com>,
 Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Mimi Zohar <zohar@linux.vnet.ibm.com>,
 Thiago Jung Bauermann <bauerman@linux.ibm.com>,
 Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org,
 kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <cover.1550097697.git.igor.stoppa@huawei.com>
 <b99f0de701e299b9d25ce8cfffa3387b9687f5fc.1550097697.git.igor.stoppa@huawei.com>
 <20190214112849.GM32494@hirez.programming.kicks-ass.net>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <6e9ec71c-ee75-9b1e-9ff8-a3210030e85d@gmail.com>
Date: Fri, 15 Feb 2019 01:10:33 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190214112849.GM32494@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 14/02/2019 13:28, Peter Zijlstra wrote:
> On Thu, Feb 14, 2019 at 12:41:32AM +0200, Igor Stoppa wrote:

[...]

>> +#define wr_rcu_assign_pointer(p, v) ({	\
>> +	smp_mb();			\
>> +	wr_assign(p, v);		\
>> +	p;				\
>> +})
> 
> This requires that wr_memcpy() (through wr_assign) is single-copy-atomic
> for native types. There is not a comment in sight that states this.

Right, I kinda expected native-aligned <-> atomic, but it's not 
necessarily true. It should be confirmed when enabling write rare on a 
new architecture. I'll add the comment.

> Also, is this true of x86/arm64 memcpy ?


For x86_64:
https://elixir.bootlin.com/linux/v5.0-rc6/source/arch/x86/include/asm/uaccess.h#L462 
  the mov"itype"  part should deal with atomic copy of native, aligned 
types.


For arm64:
https://elixir.bootlin.com/linux/v5.0-rc6/source/arch/arm64/lib/copy_template.S#L110 
.Ltiny15 deals with copying less than 16 bytes, which includes pointers. 
When the data is aligned, the copy of a pointer should be atomic.


--
igor


Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E05A38E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 06:53:48 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id q62so8343412pgq.9
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 03:53:48 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id z9si4265147pgf.54.2019.01.18.03.53.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 03:53:47 -0800 (PST)
Subject: Re: Need help: how to locate failure from irq_chip subsystem
References: <CAOuPNLj4QzNDt0npZn2LhZTFgDNJ1CsWPw3=wvUuxnGtQW308g@mail.gmail.com>
 <bceb32be-d508-c2a4-fa81-ab8b90323d3f@codeaurora.org>
 <CAOuPNLiNtPFksCuZF_vL6+YuLG0i0umzQhMCyEN69h9tySn2Vw@mail.gmail.com>
 <57ff3437-47b5-fe92-d576-084ce26aa5d8@codeaurora.org>
 <CAOuPNLjjd67FnjaHbJj_auD-EWnbc+6sc+hcT_HE6fjeKhEQrw@mail.gmail.com>
From: Sai Prakash Ranjan <saiprakash.ranjan@codeaurora.org>
Message-ID: <1ffe2b68-c87b-aa19-08af-b811063b3310@codeaurora.org>
Date: Fri, 18 Jan 2019 17:23:42 +0530
MIME-Version: 1.0
In-Reply-To: <CAOuPNLjjd67FnjaHbJj_auD-EWnbc+6sc+hcT_HE6fjeKhEQrw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Agarwal <pintu.ping@gmail.com>
Cc: open list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-mm@kvack.org, linux-pm@vger.kernel.org, kernelnewbies@kernelnewbies.org

On 1/18/2019 4:50 PM, Pintu Agarwal wrote:
>>>> Could you please tell which QCOM SoC this board is based on?
>>>>
>>>
>>> Snapdragon 845 with kernel 4.9.x
>>> I want to know from which subsystem it is triggered:drivers/soc/qcom/
>>>
>>
>> Irqchip driver is "drivers/irqchip/irq-gic-v3.c". The kernel you are
>> using is msm-4.9 I suppose or some other kernel?
>>
> Yes, I am using customized version of msm-4.9 kernel based on Android.
> And yes the irqchip driver is: irq-gic-v3, which I can see from config.
> 
> But, what I wanted to know is, how to find out which driver module
> (hopefully under: /drivers/soc/qcom/) that register with this
> irq_chip, is getting triggered at the time of crash ?
> So, that I can implement irq_hold function for it, which is the cause of crash.
> 

Hmm, since this is a bootup crash, *initcall_debug* should help.
Add "initcall_debug ignore_loglevel" to kernel commandline and
check the last log before crash.

- Sai

-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a member
of Code Aurora Forum, hosted by The Linux Foundation

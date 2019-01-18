Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 326D78E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 05:24:40 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id g188so8166631pgc.22
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 02:24:40 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id u5si4036615pgi.146.2019.01.18.02.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 02:24:38 -0800 (PST)
Subject: Re: Need help: how to locate failure from irq_chip subsystem
References: <CAOuPNLj4QzNDt0npZn2LhZTFgDNJ1CsWPw3=wvUuxnGtQW308g@mail.gmail.com>
From: Sai Prakash Ranjan <saiprakash.ranjan@codeaurora.org>
Message-ID: <bceb32be-d508-c2a4-fa81-ab8b90323d3f@codeaurora.org>
Date: Fri, 18 Jan 2019 15:54:33 +0530
MIME-Version: 1.0
In-Reply-To: <CAOuPNLj4QzNDt0npZn2LhZTFgDNJ1CsWPw3=wvUuxnGtQW308g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Agarwal <pintu.ping@gmail.com>, open list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-mm@kvack.org, linux-pm@vger.kernel.org, kernelnewbies@kernelnewbies.org

Hi Pintu-san,

On 1/18/2019 3:38 PM, Pintu Agarwal wrote:
> Hi All,
> 
> Currently, I am trying to debug a boot up crash on some qualcomm
> snapdragon arm64 board with kernel 4.9.
> I could find the cause of the failure, but I am unable to locate from
> which subsystem/drivers this is getting triggered.
> If you have any ideas or suggestions to locate the issue, please let me know.
> 
> This is the snapshot of crash logs:
> [    6.907065] Unable to handle kernel NULL pointer dereference at
> virtual address 00000000
> [    6.973938] PC is at 0x0
> [    6.976503] LR is at __ipipe_ack_fasteoi_irq+0x28/0x38
> [    7.151078] Process qmp_aop (pid: 24, stack limit = 0xfffffffbedc18000)
> [    7.242668] [<          (null)>]           (null)
> [    7.247416] [<ffffff9469f8d2e0>] __ipipe_dispatch_irq+0x78/0x340
> [    7.253469] [<ffffff9469e81564>] __ipipe_grab_irq+0x5c/0xd0
> [    7.341538] [<ffffff9469e81d68>] gic_handle_irq+0xc0/0x154
> 
> [    6.288581] [PINTU]: __ipipe_ack_fasteoi_irq - called
> [    6.293698] [PINTU]: __ipipe_ack_fasteoi_irq:
> desc->irq_data.chip->irq_hold is NULL
> 
> When I check, I found that the irq_hold implementation is missing in
> one of the irq_chip driver (expected by ipipe), which I am supposed to
> implement.
> 
> But I am unable to locate which irq_chip driver.
> If there are any good techniques to locate this in kernel, please help.
> 

Could you please tell which QCOM SoC this board is based on?

Thanks,
Sai

-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a member
of Code Aurora Forum, hosted by The Linux Foundation

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id B8FD98E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 06:20:22 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id w22so5721884vsj.15
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 03:20:22 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b19sor2530773uak.40.2019.01.18.03.20.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 03:20:21 -0800 (PST)
MIME-Version: 1.0
References: <CAOuPNLj4QzNDt0npZn2LhZTFgDNJ1CsWPw3=wvUuxnGtQW308g@mail.gmail.com>
 <bceb32be-d508-c2a4-fa81-ab8b90323d3f@codeaurora.org> <CAOuPNLiNtPFksCuZF_vL6+YuLG0i0umzQhMCyEN69h9tySn2Vw@mail.gmail.com>
 <57ff3437-47b5-fe92-d576-084ce26aa5d8@codeaurora.org>
In-Reply-To: <57ff3437-47b5-fe92-d576-084ce26aa5d8@codeaurora.org>
From: Pintu Agarwal <pintu.ping@gmail.com>
Date: Fri, 18 Jan 2019 16:50:10 +0530
Message-ID: <CAOuPNLjjd67FnjaHbJj_auD-EWnbc+6sc+hcT_HE6fjeKhEQrw@mail.gmail.com>
Subject: Re: Need help: how to locate failure from irq_chip subsystem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sai Prakash Ranjan <saiprakash.ranjan@codeaurora.org>
Cc: open list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-mm@kvack.org, linux-pm@vger.kernel.org, kernelnewbies@kernelnewbies.org

> >> Could you please tell which QCOM SoC this board is based on?
> >>
> >
> > Snapdragon 845 with kernel 4.9.x
> > I want to know from which subsystem it is triggered:drivers/soc/qcom/
> >
>
> Irqchip driver is "drivers/irqchip/irq-gic-v3.c". The kernel you are
> using is msm-4.9 I suppose or some other kernel?
>
Yes, I am using customized version of msm-4.9 kernel based on Android.
And yes the irqchip driver is: irq-gic-v3, which I can see from config.

But, what I wanted to know is, how to find out which driver module
(hopefully under: /drivers/soc/qcom/) that register with this
irq_chip, is getting triggered at the time of crash ?
So, that I can implement irq_hold function for it, which is the cause of crash.

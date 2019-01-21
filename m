Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 24AC38E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 07:35:16 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id j123so10546912vsd.9
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 04:35:16 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l23sor7274430uar.46.2019.01.21.04.35.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 04:35:15 -0800 (PST)
MIME-Version: 1.0
References: <CAOuPNLj4QzNDt0npZn2LhZTFgDNJ1CsWPw3=wvUuxnGtQW308g@mail.gmail.com>
 <bceb32be-d508-c2a4-fa81-ab8b90323d3f@codeaurora.org> <CAOuPNLiNtPFksCuZF_vL6+YuLG0i0umzQhMCyEN69h9tySn2Vw@mail.gmail.com>
 <57ff3437-47b5-fe92-d576-084ce26aa5d8@codeaurora.org> <CAOuPNLjjd67FnjaHbJj_auD-EWnbc+6sc+hcT_HE6fjeKhEQrw@mail.gmail.com>
 <1ffe2b68-c87b-aa19-08af-b811063b3310@codeaurora.org>
In-Reply-To: <1ffe2b68-c87b-aa19-08af-b811063b3310@codeaurora.org>
From: Pintu Agarwal <pintu.ping@gmail.com>
Date: Mon, 21 Jan 2019 18:05:03 +0530
Message-ID: <CAOuPNLgM-aV51_L4WzwSGPQ4daVqWBgs8mQ8Gdw-f4Kdmadx1Q@mail.gmail.com>
Subject: Re: Need help: how to locate failure from irq_chip subsystem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sai Prakash Ranjan <saiprakash.ranjan@codeaurora.org>
Cc: open list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-mm@kvack.org, linux-pm@vger.kernel.org, kernelnewbies@kernelnewbies.org

On Fri, Jan 18, 2019 at 5:23 PM Sai Prakash Ranjan
<saiprakash.ranjan@codeaurora.org> wrote:
>
> On 1/18/2019 4:50 PM, Pintu Agarwal wrote:
> >>>> Could you please tell which QCOM SoC this board is based on?
> >>>>
> >>>
> >>> Snapdragon 845 with kernel 4.9.x
> >>> I want to know from which subsystem it is triggered:drivers/soc/qcom/
> >>>
> >>
> >> Irqchip driver is "drivers/irqchip/irq-gic-v3.c". The kernel you are
> >> using is msm-4.9 I suppose or some other kernel?
> >>
> > Yes, I am using customized version of msm-4.9 kernel based on Android.
> > And yes the irqchip driver is: irq-gic-v3, which I can see from config.
> >
> > But, what I wanted to know is, how to find out which driver module
> > (hopefully under: /drivers/soc/qcom/) that register with this
> > irq_chip, is getting triggered at the time of crash ?
> > So, that I can implement irq_hold function for it, which is the cause of crash.
> >
>
> Hmm, since this is a bootup crash, *initcall_debug* should help.
> Add "initcall_debug ignore_loglevel" to kernel commandline and
> check the last log before crash.
>

OK thanks Sai, for your suggestions.
Yes, I already tried that, but it did not help much.

Anyways, I could finally find the culprit driver, from where null
reference is coming.
So, that issue is fixed.
But, now I am looking into another issue.
If required, I will post further...

Thanks,
Pintu

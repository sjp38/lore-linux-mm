Return-Path: <SRS0=AIe5=P2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BBCEC43387
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 10:48:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC2502087E
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 10:48:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="C6MnRUdv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC2502087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69F788E0003; Fri, 18 Jan 2019 05:48:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64F498E0002; Fri, 18 Jan 2019 05:48:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 519328E0003; Fri, 18 Jan 2019 05:48:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1788E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 05:48:45 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id w206so5708157vsc.2
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 02:48:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/6xliivq0weCXLfwCUUU2y3nNNwTp933/QmOo/bU0eY=;
        b=gth3GDfWWAUF6H/WOhVl467P7dcnbTAcvY1XziTNPFKsfZuWBo71Xiaam1YTjw2zFe
         JMVbTb0LNM1XYWLSw1CNb3011zgg3Dhc+Qrn1Ph8zAK1WOIvMkL3LVoZBWlWJdHsCVnZ
         tI4PYDUrLGCWezzGVZXdD2mUy2tTtD1TWtijaJG4lE9iZiCNPCMoVbasNDh3wh7rrFnE
         p18JIJbuTxAFqe/nkUo5KzFXeVeKMfHijzSrhzSM4HubBkfCVwqvCFBbga3fe7/yxFoy
         oGM9vOI/0Y/fkDfN+RSoymv0jZKpY3dd9PG15jru7m04VefufxLAspQTjicNgrWsSe62
         nM4A==
X-Gm-Message-State: AJcUukdPzeSVE5iqtU9vLOecMo3lPbNJZuXDED7xaMX4vTlDrveHpuhz
	R+V48D6Lg6fiudJsGCtiQV1eiFYeRmpNQpiW6qs77Um92t1QyFmmdXHF5NJPHZyd4Wg6gqcEHf1
	h/pFT0w7+1TwAkDCyj8r/ZADZ8bqwjPM05PMLhL7f+xTykdiowO7zF68T90vf5UN+lNa59IcqfE
	NrysV5iLavviMbis+CTXWosI6Zl95dy2mE+nC+EtrHF27HlmQ1AxfS+VFvN+Q6+tHoGUUvzSG+Z
	JAf2xNgJUqkXFJuf1m4GeLsk9fZvoZKvJQm7AB6Z+xj781A1QjZbrrixeYf85BvbIEDWSSgx1m4
	sVl34I9ZKNBaTykULOmxIDOQHurD21oji7fsYZRkMVNjsROpTOciOvT+JG9UQ3DNeDVbtX9TW5c
	M
X-Received: by 2002:a1f:aa44:: with SMTP id t65mr7017153vke.66.1547808524743;
        Fri, 18 Jan 2019 02:48:44 -0800 (PST)
X-Received: by 2002:a1f:aa44:: with SMTP id t65mr7017140vke.66.1547808524057;
        Fri, 18 Jan 2019 02:48:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547808524; cv=none;
        d=google.com; s=arc-20160816;
        b=NptNH0aRIhTa0d1ERnXxemaWaE8NfVWmKHyyPAH94n8CwlqvP/IcbU610RQN25QqMc
         1JWr252CADyYvY6z+W8bdkwBcOUiAoEONA92lqaduRIRaAile65PIVA66tlHA9QDay5u
         eGuYq9pXY/n2WjSphTgTBEc2/CQ80dKpjNEN635PUcEFnMZCS96TptDnAgAhgTKjXdOr
         AzBT6/vL9hWjmT+vLqpKJpSDPyOcYrcI6Nj+AEDAxzmePEb1oYxTC8b68dGjriqh4PzU
         x3bZk62/5yQTCLsDwEIsYNksaXwJAyvTmW4R/FNnNoBvNEwt5QSFC+Yn+img5iHSEcwj
         AvQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/6xliivq0weCXLfwCUUU2y3nNNwTp933/QmOo/bU0eY=;
        b=LU+nl613HL+juQrmN9Njba8yVYqlsJ1SuR1rB1LPXtdWQTeWblDqN4EuqQtKbVDtzp
         Q/abWAagWdOb+kx58wh0Nn/UGMTGbquh9uYTbN4QR4/J3KBDbjuuS6W7n5kAq2nOUfCF
         EP+b+FnGWxPvU/7u5UWOXOKxeyX9KmIN9FTZbLtIATOSLcfmmRNxA3s4uyhqqavKJfWP
         BckFUYl+eQ8ItWVNGtnmmde/8QpyUg9W0eLB4kGyFNBNXz6jTK0yr53q9dqOZO6+MOFp
         p+2kApTuFmuSLDqyJoGV90buWTIq4dE7xp0+lu+hiSIg8S9JjLHZ2RdQq4oWyJein+79
         WbHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=C6MnRUdv;
       spf=pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pintu.ping@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g18sor2635111vsf.34.2019.01.18.02.48.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 02:48:44 -0800 (PST)
Received-SPF: pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=C6MnRUdv;
       spf=pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pintu.ping@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/6xliivq0weCXLfwCUUU2y3nNNwTp933/QmOo/bU0eY=;
        b=C6MnRUdvpvjVi5Kc8Lceq9DKjFe5J546YEJCUr3Sbn1TcFwfxAzTWbjASQrCNA6aGh
         Nu/6WGPZxYRxA/SP6he88jxtClUyBRL+kl2le9yc41CozxPqdcpzZtFWFFtmSk9q/IrS
         HHahJkKxV2iH2vPXAwYh3qMunjbO0J2LEhLf8NG3QzP8ns6wtmr5u32u7kKLP3eWButc
         TZ8XelSo1gGw4j3PnEwKa80b1ml+h4JXNIkIuun5HIV0fRllQsNUfe7GN9YlNKAObGGo
         kM32yguM1ceiCrAWAVr68YUwEHv2cai2UhJ0xo8+YTnRF8yU+9/mncUtqtLonPnGQH8M
         kfng==
X-Google-Smtp-Source: ALg8bN7HsppUgj5spIWajytKcejIfmTNluhxxl0gRonQb5lcTa162V7q5iApGv92T5XidVHBMY1/wVNcnfaji/TcPRo=
X-Received: by 2002:a67:f793:: with SMTP id j19mr6934457vso.196.1547808523523;
 Fri, 18 Jan 2019 02:48:43 -0800 (PST)
MIME-Version: 1.0
References: <CAOuPNLj4QzNDt0npZn2LhZTFgDNJ1CsWPw3=wvUuxnGtQW308g@mail.gmail.com>
 <bceb32be-d508-c2a4-fa81-ab8b90323d3f@codeaurora.org>
In-Reply-To: <bceb32be-d508-c2a4-fa81-ab8b90323d3f@codeaurora.org>
From: Pintu Agarwal <pintu.ping@gmail.com>
Date: Fri, 18 Jan 2019 16:18:32 +0530
Message-ID:
 <CAOuPNLiNtPFksCuZF_vL6+YuLG0i0umzQhMCyEN69h9tySn2Vw@mail.gmail.com>
Subject: Re: Need help: how to locate failure from irq_chip subsystem
To: Sai Prakash Ranjan <saiprakash.ranjan@codeaurora.org>
Cc: open list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, 
	Russell King - ARM Linux <linux@armlinux.org.uk>, linux-mm@kvack.org, linux-pm@vger.kernel.org, 
	kernelnewbies@kernelnewbies.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190118104832.59UQwevA6h9SDJi8b3RWZd6q1aqauExBUYXdZzdy5Yc@z>

On Fri, Jan 18, 2019 at 3:54 PM Sai Prakash Ranjan
<saiprakash.ranjan@codeaurora.org> wrote:
>
> Hi Pintu-san,
>
> On 1/18/2019 3:38 PM, Pintu Agarwal wrote:
> > Hi All,
> >
> > Currently, I am trying to debug a boot up crash on some qualcomm
> > snapdragon arm64 board with kernel 4.9.
> > I could find the cause of the failure, but I am unable to locate from
> > which subsystem/drivers this is getting triggered.
> > If you have any ideas or suggestions to locate the issue, please let me know.
> >
> > This is the snapshot of crash logs:
> > [    6.907065] Unable to handle kernel NULL pointer dereference at
> > virtual address 00000000
> > [    6.973938] PC is at 0x0
> > [    6.976503] LR is at __ipipe_ack_fasteoi_irq+0x28/0x38
> > [    7.151078] Process qmp_aop (pid: 24, stack limit = 0xfffffffbedc18000)
> > [    7.242668] [<          (null)>]           (null)
> > [    7.247416] [<ffffff9469f8d2e0>] __ipipe_dispatch_irq+0x78/0x340
> > [    7.253469] [<ffffff9469e81564>] __ipipe_grab_irq+0x5c/0xd0
> > [    7.341538] [<ffffff9469e81d68>] gic_handle_irq+0xc0/0x154
> >
> > [    6.288581] [PINTU]: __ipipe_ack_fasteoi_irq - called
> > [    6.293698] [PINTU]: __ipipe_ack_fasteoi_irq:
> > desc->irq_data.chip->irq_hold is NULL
> >
> > When I check, I found that the irq_hold implementation is missing in
> > one of the irq_chip driver (expected by ipipe), which I am supposed to
> > implement.
> >
> > But I am unable to locate which irq_chip driver.
> > If there are any good techniques to locate this in kernel, please help.
> >
>
> Could you please tell which QCOM SoC this board is based on?
>

Snapdragon 845 with kernel 4.9.x
I want to know from which subsystem it is triggered:drivers/soc/qcom/

>
> --
> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a member
> of Code Aurora Forum, hosted by The Linux Foundation


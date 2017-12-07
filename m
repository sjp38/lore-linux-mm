Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F3EE96B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 14:27:31 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id n13so3840779wmc.3
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:27:31 -0800 (PST)
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net. [2001:4b98:c:538::194])
        by mx.google.com with ESMTPS id h1si4093993wmd.243.2017.12.07.11.27.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 11:27:30 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	(Authenticated sender: pshelar@ovn.org)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id AFCF0C5A49
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 20:27:30 +0100 (CET)
Received: by mail-wm0-f51.google.com with SMTP id f140so14739403wmd.2
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 11:27:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1510959741-31109-7-git-send-email-yang.s@alibaba-inc.com>
References: <1510959741-31109-1-git-send-email-yang.s@alibaba-inc.com> <1510959741-31109-7-git-send-email-yang.s@alibaba-inc.com>
From: Pravin Shelar <pshelar@ovn.org>
Date: Thu, 7 Dec 2017 11:27:29 -0800
Message-ID: <CAOrHB_CiK-A0nphB2xVTG_5P_xeFOkg0xc6iNNbT=MXq1XgU=A@mail.gmail.com>
Subject: Re: [ovs-dev] [PATCH 7/8] net: ovs: remove unused hardirq.h
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: linux-kernel@vger.kernel.org, ovs dev <dev@openvswitch.org>, Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm@kvack.org, Pravin Shelar <pshelar@nicira.com>, linux-crypto@vger.kernel.org, linux-fsdevel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>

On Fri, Nov 17, 2017 at 3:02 PM, Yang Shi <yang.s@alibaba-inc.com> wrote:
> Preempt counter APIs have been split out, currently, hardirq.h just
> includes irq_enter/exit APIs which are not used by openvswitch at all.
>
> So, remove the unused hardirq.h.
>
> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> Cc: Pravin Shelar <pshelar@nicira.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: dev@openvswitch.org

Acked-by: Pravin B Shelar <pshelar@ovn.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

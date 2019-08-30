Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E617CC3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 18:06:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9837D23407
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 18:06:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="KujSBNcd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9837D23407
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2161D6B0006; Fri, 30 Aug 2019 14:06:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C7406B0008; Fri, 30 Aug 2019 14:06:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B5E46B000A; Fri, 30 Aug 2019 14:06:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0087.hostedemail.com [216.40.44.87])
	by kanga.kvack.org (Postfix) with ESMTP id D88006B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 14:06:58 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 55FC21E08F
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 18:06:58 +0000 (UTC)
X-FDA: 75879875316.01.wave71_3cd018fc74a24
X-HE-Tag: wave71_3cd018fc74a24
X-Filterd-Recvd-Size: 5659
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 18:06:57 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id 4so6918400qki.6
        for <linux-mm@kvack.org>; Fri, 30 Aug 2019 11:06:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Eh/2xbIwVNXN4tuwrJrTCLRZrKWzmJtO4ybIQHEw8mA=;
        b=KujSBNcd5SoFevO+SIWyVxNL2n8N59q866IgsFF+b4gnTMQoPBc4O3jXPhX+91LAlL
         EHWO226T7vbNq9hI1ljfS3DukO6LCC2psnfnNm66EMZXiODoPgArR8L90Tkqu1u7swFF
         ipL5OtwUyVIeld46J6UdhSPiznQJkydM2RVU342XX28AIeIO3WIME/q8Rs0yIt1vUThB
         /xJf00BWO/h6v/cyK8vHapVVSmQ8pebW1wGfPGTJzQ4GMJXdViWdl67rGFycGbuhVX81
         75KGcXJF/MzMXna8XIJwG0r14xvvRbIefhO0lzEgrkyS4ShAciBA0KThkeuYUnDUgvhR
         hhpw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Eh/2xbIwVNXN4tuwrJrTCLRZrKWzmJtO4ybIQHEw8mA=;
        b=aWZ/lXUPvBKE/OVaUDjzd/EUdTLaLD1pgyVtBcZY+cFh/isJN7IE+4hXW8U0+S6qjf
         xMdLGHNjxX/dQHFHY63w/h4Zr4XRBOoSW1Ted0FTUVVeHm2NhsR5VedIP4z5JVaXtSTM
         chlBF64dSf8jTtiGLev0+KyLB0lYqCl+ooBtg890uJRdRKkhluPewQjoDyveWk2+D1PP
         dYwTpjFOyUX3cLOdKLJBQBLZe4/DlmMvHnc6pvEcPAorauN/LWX3sGf6P80WiyvDFcAp
         WoA5T//ME1ZrxL6RFjMeCqIDKOQpGU0RLeQROZi83GD1r8qt5RIMu0gZowSYSBmLOoIQ
         eVjw==
X-Gm-Message-State: APjAAAXHN1kiPe69/jVcyRnfvACcL46e3yMn0e5gH6xvetKyWh25vR8W
	cDhaUezydenFksgyrOiPmk14Zw==
X-Google-Smtp-Source: APXvYqypwYuBFK8wvrgeET1bmyo6DjclpnUDfuFsrQR2cf917OvSt7wSb8I7zRi8wHlfjL+eSSoXaQ==
X-Received: by 2002:a37:8905:: with SMTP id l5mr16945385qkd.152.1567188417069;
        Fri, 30 Aug 2019 11:06:57 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id e2sm2939266qki.70.2019.08.30.11.06.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Aug 2019 11:06:56 -0700 (PDT)
Message-ID: <1567188415.5576.34.camel@lca.pw>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
From: Qian Cai <cai@lca.pw>
To: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Fri, 30 Aug 2019 14:06:55 -0400
In-Reply-To: <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
References: <1567177025-11016-1-git-send-email-cai@lca.pw>
	 <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
	 <1567178728.5576.32.camel@lca.pw>
	 <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-08-30 at 18:15 +0200, Eric Dumazet wrote:
> 
> On 8/30/19 5:25 PM, Qian Cai wrote:
> > On Fri, 2019-08-30 at 17:11 +0200, Eric Dumazet wrote:
> > > 
> > > On 8/30/19 4:57 PM, Qian Cai wrote:
> > > > When running heavy memory pressure workloads, the system is throwing
> > > > endless warnings below due to the allocation could fail from
> > > > __build_skb(), and the volume of this call could be huge which may
> > > > generate a lot of serial console output and cosumes all CPUs as
> > > > warn_alloc() could be expensive by calling dump_stack() and then
> > > > show_mem().
> > > > 
> > > > Fix it by silencing the warning in this call site. Also, it seems
> > > > unnecessary to even print a warning at all if the allocation failed in
> > > > __build_skb(), as it may just retransmit the packet and retry.
> > > > 
> > > 
> > > Same patches are showing up there and there from time to time.
> > > 
> > > Why is this particular spot interesting, against all others not adding
> > > __GFP_NOWARN ?
> > > 
> > > Are we going to have hundred of patches adding __GFP_NOWARN at various
> > > points,
> > > or should we get something generic to not flood the syslog in case of
> > > memory
> > > pressure ?
> > > 
> > 
> > From my testing which uses LTP oom* tests. There are only 3 places need to
> > be
> > patched. The other two are in IOMMU code for both Intel and AMD. The place
> > is
> > particular interesting because it could cause the system with floating
> > serial
> > console output for days without making progress in OOM. I suppose it ends up
> > in
> > a looping condition that warn_alloc() would end up generating more calls
> > into
> > __build_skb() via ksoftirqd.
> > 
> 
> Yes, but what about other tests done by other people ?

Sigh, I don't know what tests do you have in mind. I tried many memory pressure
tests including LTP, stress-ng, and mmtests etc running for years. I don't
recall see other places that could loop like this for days.

> 
> You do not really answer my last question, which was really the point I tried
> to make.
> 
> If there is a risk of flooding the syslog, we should fix this generically
> in mm layer, not adding hundred of __GFP_NOWARN all over the places.
> 
> Maybe just make __GFP_NOWARN the default, I dunno.

I don't really see how it could end up with adding hundred of _GFP_NOWARN in the
kernel code. If there is really a hundred places could loop like this, it may
make more sense looking into a general solution.


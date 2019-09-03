Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46FB0C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 21:42:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08AC522CF7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 21:42:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="O1AJjw9H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08AC522CF7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D75F6B0007; Tue,  3 Sep 2019 17:42:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 861EC6B0008; Tue,  3 Sep 2019 17:42:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 701136B000A; Tue,  3 Sep 2019 17:42:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0137.hostedemail.com [216.40.44.137])
	by kanga.kvack.org (Postfix) with ESMTP id 490A16B0007
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 17:42:32 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D55D1180AD805
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 21:42:31 +0000 (UTC)
X-FDA: 75894933702.14.shock16_8a73f85bbfd31
X-HE-Tag: shock16_8a73f85bbfd31
X-Filterd-Recvd-Size: 6090
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 21:42:31 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id o12so10353875qtf.3
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 14:42:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Pl0EFO8E1nfGtt6lAyaMFxbDT0oySOj2vcl1/yE6fuc=;
        b=O1AJjw9H+q73tzV8SB4rLexieHhdXCpsG0KlCAt7kOVuqXmwHubQrJbyjHWSKgI+wD
         dpXLwWNGmdiAixAuxOZWkUIC/v1edpjmLJS33gaWveupe3ifXG0+Hz/8Lg8t2xH2395Q
         KG3gUrFgoBti/TFwbEDjB8B1SLpMCWD0Gl7MnDjnUc+8narW/tU/cDNATM480b+1qIr4
         /99TzaSZxKMKlVN1DFVVd3OPQZGc6CzY8ECuZNiMpHJMP0+vX3LZJQkYSBvm5Ls/KB5L
         /eDn1+QA1h5z7oG2w62KhZNsucEoIVbp9U5l+/4HSXAF6lBe/XdMUCioAP2LM1wQOmDU
         kz8A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Pl0EFO8E1nfGtt6lAyaMFxbDT0oySOj2vcl1/yE6fuc=;
        b=UkF6GuSewUc5HDxzaeF6sWKaWwzOkWLPTpeJ178qEYwiBv9WdfkncZoj5Ttvnedb8f
         AUVMKKTujxFS8h9TXj89U9oCwaYt3Ioi2rhsCz5MYZ44aqql5qefKlK8ULoYVw5JWWTA
         IcIb03n6a+UKaInzCpGVd9Ff1ydfxkDKL+JtOs1GOv69v58FkhKhX5EmCSHLkYCAUwLs
         2KUhb6Li7PvnphDiCdjcoU7wg28uGVPpoAOvwewu+zOutNzwYSMSHDHPMMmGWfyW6cC1
         p/vwwkm4R9Vr0u1//BsjzzVcXGlQrQu4IZsY/SZH1WTuTB+pNdthnekmd75V+gJZmhc5
         YNdw==
X-Gm-Message-State: APjAAAXyG13Pe2edmVuCavrtFBdeUNb66b4+227Bf2oIlpICcVFYAshz
	82GV0Fqh4JLHq35ORXfzJDnHPA==
X-Google-Smtp-Source: APXvYqxiY0uxaPcETg9MrwEvJU+9N/SUjCvN24j9vnpNDyM0XRV86hk6cR3lDrnZPxruLaXF6CMRTg==
X-Received: by 2002:ac8:53d6:: with SMTP id c22mr11155371qtq.381.1567546950696;
        Tue, 03 Sep 2019 14:42:30 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id o9sm8933907qtr.71.2019.09.03.14.42.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Sep 2019 14:42:29 -0700 (PDT)
Message-ID: <1567546948.5576.68.camel@lca.pw>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
From: Qian Cai <cai@lca.pw>
To: Michal Hocko <mhocko@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net, 
	netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Tue, 03 Sep 2019 17:42:28 -0400
In-Reply-To: <20190903185305.GA14028@dhcp22.suse.cz>
References: <1567177025-11016-1-git-send-email-cai@lca.pw>
	 <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
	 <1567178728.5576.32.camel@lca.pw>
	 <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
	 <20190903132231.GC18939@dhcp22.suse.cz> <1567525342.5576.60.camel@lca.pw>
	 <20190903185305.GA14028@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-09-03 at 20:53 +0200, Michal Hocko wrote:
> On Tue 03-09-19 11:42:22, Qian Cai wrote:
> > On Tue, 2019-09-03 at 15:22 +0200, Michal Hocko wrote:
> > > On Fri 30-08-19 18:15:22, Eric Dumazet wrote:
> > > > If there is a risk of flooding the syslog, we should fix this
> > > > generically
> > > > in mm layer, not adding hundred of __GFP_NOWARN all over the plac=
es.
> > >=20
> > > We do already ratelimit in warn_alloc. If it isn't sufficient then =
we
> > > can think of a different parameters. Or maybe it is the ratelimitin=
g
> > > which doesn't work here. Hard to tell and something to explore.
> >=20
> > The time-based ratelimit won't work for skb_build() as when a system =
under
> > memory pressure, and the CPU is fast and IO is so slow, it could take=
 a long
> > time to swap and trigger OOM.
>=20
> I really do not understand what does OOM and swapping have to do with
> the ratelimiting here. The sole purpose of the ratelimit is to reduce
> the amount of warnings to be printed. Slow IO might have an effect on
> when the OOM killer is invoked but atomic allocations are not directly
> dependent on IO.

When there is a heavy memory pressure, the system is trying hard to recla=
im
memory to fill up the watermark. However, the IO is slow to page out, but=
 the
memory pressure keep draining atomic reservoir, and some of those skb_bui=
ld()
will fail eventually.

Only if there is a fast IO, it will finish swapping sooner and then invok=
e the
OOM to end the memory pressure.

>=20
> > I suppose what happens is those skb_build() allocations are from soft=
irq,
> > and
> > once one of them failed, it calls printk() which generates more inter=
rupts.
> > Hence, the infinite loop.
>=20
> Please elaborate more.
>=20

If you look at the original report, the failed allocation dump_stack() is=
,

=C2=A0<IRQ>
=C2=A0warn_alloc.cold.43+0x8a/0x148
=C2=A0__alloc_pages_nodemask+0x1a5c/0x1bb0
=C2=A0alloc_pages_current+0x9c/0x110
=C2=A0allocate_slab+0x34a/0x11f0
=C2=A0new_slab+0x46/0x70
=C2=A0___slab_alloc+0x604/0x950
=C2=A0__slab_alloc+0x12/0x20
=C2=A0kmem_cache_alloc+0x32a/0x400
=C2=A0__build_skb+0x23/0x60
=C2=A0build_skb+0x1a/0xb0
=C2=A0igb_clean_rx_irq+0xafc/0x1010 [igb]
=C2=A0igb_poll+0x4bb/0xe30 [igb]
=C2=A0net_rx_action+0x244/0x7a0
=C2=A0__do_softirq+0x1a0/0x60a
=C2=A0irq_exit+0xb5/0xd0
=C2=A0do_IRQ+0x81/0x170
=C2=A0common_interrupt+0xf/0xf
=C2=A0</IRQ>

Since it has no __GFP_NOWARN to begin with, it will call,

printk
  vprintk_default
    vprintk_emit
      wake_up_klogd
        irq_work_queue
          __irq_work_queue_local
            arch_irq_work_raise
              apic->send_IPI_self(IRQ_WORK_VECTOR)
                smp_irq_work_interrupt
                  exiting_irq
                    irq_exit

and end up processing pending=C2=A0net_rx_action softirqs again which are=
 plenty due
to connected via ssh etc.


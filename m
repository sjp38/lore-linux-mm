Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C2DDC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:02:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64649217D9
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:02:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="puIBXxat"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64649217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECF128E0160; Mon, 11 Feb 2019 16:02:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E57438E0155; Mon, 11 Feb 2019 16:02:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1E308E0160; Mon, 11 Feb 2019 16:02:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8CB8E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:02:16 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id x64so215374ywc.6
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:02:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=M4MOYTgSy8gNryYGzYYrK875Zjjp0bQsk1YfhE9GqXc=;
        b=SXQp5n22YzxuwyOWlNpNqycnXtwrUHprQ9+tp1Yf0OGG4KADS07Ryr0R5+D1bOonYq
         yfgDW2mu+pkjHpVw+tkksAfzt5gMx4pv5EgpMjnukkTD7EANx6ZR+uLCN0px2jh5Sq07
         u02tOwfruTV80Uu2E+bn2TiqHiH4aLHbAa5KkQTLfHG3i3G3ZLB04cX+y3tVAK+iEDeb
         r6UwB8vlv70m5uzPRbdVkCK+Z5PlvMBn6G9LjMe0TLMC7pCFwP6N8NHOxVZevKwdJyz+
         hE97VTCTajeBAoAXw9fKmeoUwnpTY3Eh9zS6M4XKcodkphYckFUkB91H1oecJ+iXPLN7
         7YpA==
X-Gm-Message-State: AHQUAuaFRYay6j2MSdUut1SPbs0Ks2EMM5+3Ink9LG/jSdq/rE+IGz5u
	h7A+4Il9Yauf5qxUXQHZqX6kUz/jYrOITaoQJOHBtzjvkviGSEFI/cZWA/02f0MrXEm60RSk2F+
	/vXu4mdYV97cuIOOM3BZ6ttb0rfQnkwoh1Pl7M+uzYfD9m1qTYnDi7jYxC7ULcRjmZcH2TLm21O
	Z/c+7XTkf6YkaJyVMrUuJz1PzucDtakbmp8wrC2RwuEkbq3MocQVOnfdrPlrhbwodC7gQ5RqRLn
	ZNnlgeR6V6XjcnsVvN9pF7q9b3VV8zI3VZjBjeQ+z4nW15TfigtemX+OnrU+Kbhlmqp1ElC/IV6
	3zrxwVLTyEzGOkEEfajpIdIgieZq1Jkw7dZgbq6ls0RBro7nM6B8E42u/VIT8PXpwm2Jr1+WqPL
	D
X-Received: by 2002:a81:980b:: with SMTP id p11mr174536ywg.22.1549918936256;
        Mon, 11 Feb 2019 13:02:16 -0800 (PST)
X-Received: by 2002:a81:980b:: with SMTP id p11mr174488ywg.22.1549918935560;
        Mon, 11 Feb 2019 13:02:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549918935; cv=none;
        d=google.com; s=arc-20160816;
        b=ftLFe7bDd73fNjCeTcrUNEaJaI6SsLRGyk81gAQZQqIcYtUxpEqXlYjAyNnUq1LhgM
         fP5rfDXMc8pPbTtV9nWzt93L+TxZB1m8aA8/7c/H2kLmgNVHv6B01IF04wL7sokX6e72
         o8Zh0XgudqlfzaAUWBJH0oSbaQNX0Hwljhw6+7dfQBupsMbuED9VeA2HGuE0t8bjoQBc
         orxKqtpIMNq5cvtp9ln+98xuyXFN9JTOxPqwD9On6V47dpK1VQY5+phjNMj/u2+4vPS3
         ca9fXMf8COrpfLnUUELD/LrdsdTABDxZXARaMONcJZLmr63PK7I53iEC3QNNJnOxs9Sd
         DFXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=M4MOYTgSy8gNryYGzYYrK875Zjjp0bQsk1YfhE9GqXc=;
        b=cxiwwonVkWws/yd3StRDk6TLfESCri/sXe/EtjnBU8S44/t8ZyZ+1iAmEwEgXJJ439
         2p7j3Ryw2snWZgbIe2o3u+B4GouViySlS5II8TCGgyEGX4khgHoNg/CbzhuWL5ZrfbLS
         g3iEqOAvhBiEWAQqEmXTfFkWYhTBFpJNPDNVLqNfIIhgzhsol23Vo55qUDdGx/JCuQYt
         RNaJljsiTXzq0xLE462NOwX+5hxADpNe1b7bcxeo0oBMf2BKhQINmlFUFzn02QdEESv8
         WFfUws2uSkanEGH1aYkU6IBU0RwIETvvfuXf8Ed56GSdsjeSwoKQyaVujvOXuPYdBxPt
         AzJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=puIBXxat;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q125sor5426740ybc.129.2019.02.11.13.02.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 13:02:11 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=puIBXxat;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=M4MOYTgSy8gNryYGzYYrK875Zjjp0bQsk1YfhE9GqXc=;
        b=puIBXxatNSP1vZ0vL0Ol362YONqgJ1XhKPL6MjtMob6HT4g1OCOPMR2IBjIDpKN0XC
         Z6rMBKJv3bO6FNsNT4MEpIl1Hca+s59jXFt6fFmgZ5SDqxFK7vZUcShFHFGmiEi+Ss3W
         Ryten64MIaCPj3LXrldyurtpqz7ixMLiG/5gBXOBKg/voNhpMnOl1e/AWS4XgVZgIlte
         NVLw9ewz4UVfBzNZ/u0HB4zMWz0yf18z/6LBwVYna4QDz87Kgn16I9M3/yXm0dziwZEH
         loDzHWTPIo25aYLuPFhbZa88c+jXlz+SWyjjD/HihWucbxFJEfm61IvyTbPBU5t7h6pH
         3LrQ==
X-Google-Smtp-Source: AHgI3IYHhziC7OdpF/e/p5i02oj1vB6J9SUTFeYHegb6tFyKEWtwpyOeGHjIlWk44pyRloxahr16tA==
X-Received: by 2002:a5b:8c4:: with SMTP id w4mr176931ybq.44.1549918930821;
        Mon, 11 Feb 2019 13:02:10 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:6e5])
        by smtp.gmail.com with ESMTPSA id l138sm4059537ywb.4.2019.02.11.13.02.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 13:02:09 -0800 (PST)
Date: Mon, 11 Feb 2019 16:02:08 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2] mm: workingset: replace IRQ-off check with a lockdep
 assert.
Message-ID: <20190211210208.GA9580@cmpxchg.org>
References: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
 <20190211113829.sqf6bdi4c4cdd3rp@linutronix.de>
 <20190211185318.GA13953@cmpxchg.org>
 <20190211191345.lmh4kupxyta5fpja@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211191345.lmh4kupxyta5fpja@linutronix.de>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 08:13:45PM +0100, Sebastian Andrzej Siewior wrote:
> On 2019-02-11 13:53:18 [-0500], Johannes Weiner wrote:
> > On Mon, Feb 11, 2019 at 12:38:29PM +0100, Sebastian Andrzej Siewior wrote:
> > > Commit
> > > 
> > >   68d48e6a2df57 ("mm: workingset: add vmstat counter for shadow nodes")
> > > 
> > > introduced an IRQ-off check to ensure that a lock is held which also
> > > disabled interrupts. This does not work the same way on -RT because none
> > > of the locks, that are held, disable interrupts.
> > > Replace this check with a lockdep assert which ensures that the lock is
> > > held.
> > > 
> > > Cc: Peter Zijlstra <peterz@infradead.org>
> > > Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> > 
> > I'm not against checking for the lock, but if IRQs aren't disabled,
> > what ensures __mod_lruvec_state() is safe?
> 
> how do you define safe? I've been looking for dependencies of
> __mod_lruvec_state() but found only that the lock is held during the RMW
> operation with WORKINGSET_NODES idx.

These stat functions are not allowed to nest, and the executing thread
cannot migrate to another CPU during the operation, otherwise they
corrupt the state they're modifying.

They are called from interrupt handlers, such as when NR_WRITEBACK is
decreased. Thus workingset_node_update() must exclude preemption from
irq handlers on the local CPU.

They rely on IRQ-disabling to also disable CPU migration.

> >                                            I'm guessing it's because
> > preemption is disabled and irq handlers are punted to process context.
> preemption is enabled and IRQ are processed in forced-threaded mode.

That doesn't sound safe.


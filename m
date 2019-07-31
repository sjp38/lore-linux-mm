Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15B4CC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:04:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA686206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:04:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EnzJ0F54"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA686206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5838F8E0003; Wed, 31 Jul 2019 08:04:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50C3C8E0001; Wed, 31 Jul 2019 08:04:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D5EA8E0003; Wed, 31 Jul 2019 08:04:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6ED18E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:04:23 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id e20so14796452ljk.2
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:04:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=s4RPoNoetmDdSgwfGZ08wLtjU3Rl2zWouKkOWjbjMWg=;
        b=gZfSIArAVZK6MeL0gM9GsWE4kQTFMPANjQ6Ctqpyzt15W/ZBVEDS4Tu9KV5Ufesjew
         e3uncF3hRjovLUa4KuSsjtwI3b5g3aFwfB8aiwNbg/qLllg6jwqqwoMfLqRI5OBHlsqn
         6mOpqAh+kLYh7CqdLE6Yp/rkLqi0PNYusH4bNP5Cp8/vKG5CVCLLDfb5M5twQnfOkonF
         alQvAmUej1KtO7Qtd27KLDil3+t7fJot/5ltYdkSAYnWc5xRcp0mxXX4PH/0CYnBiDLr
         OBIIyoRJr1SG+gUTsUb0L7oTaKL0r/D1FYaA/nrav35JDtNURzkfzeJfUTACGLkwISsI
         rK0w==
X-Gm-Message-State: APjAAAWc99VmTrG8IXgan3rWKd2GHdeZLISKh4ks/3kwPTiKl42higuq
	Naq36jdlJ35lFSk0EzA2VqZ1eNCRMhdNnbPMBsA+R3KtLCldsEq98CAfOOGiEzRCHMXaICrm7Gj
	Gcafnl3+ibfaluwMRkVnOL9jNBf6B9gaPEtGrMoIbnR/33E+uymd1gzJlSBkEv0IVpQ==
X-Received: by 2002:a2e:8155:: with SMTP id t21mr7402192ljg.80.1564574662957;
        Wed, 31 Jul 2019 05:04:22 -0700 (PDT)
X-Received: by 2002:a2e:8155:: with SMTP id t21mr7402152ljg.80.1564574662255;
        Wed, 31 Jul 2019 05:04:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564574662; cv=none;
        d=google.com; s=arc-20160816;
        b=um5v75jQUO3sqOuZB3JsrlIper6qQ15pUoXu/w3sW1WY1bS+Fe+Gd5xv5YPthhmyJp
         SZmti2wMD2vc1w7KgrgdZSZPj5NVR+w3FecwraCy2t2tvQ29AnawIQ8/2ceOBVgEom0r
         qXnNt60+n+4Zj3m7nQT825tDq7s8uYu4exDVATIaFkqpr8YHDo4Hg5F9T8Dk7m+OyIxS
         ruvE3MivbDNR2gGQnzZ1fsiJXqkUlqv7tHMSjYmYno5MqTCq1ilPJQkGasWGH28R6qll
         U+hcUmpdopo0ITDs6N0qWH5fj+HX6OdbkM571nH0Md8hdtOp1dm/xXeBoM8dnxB3EcSO
         Kw7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=s4RPoNoetmDdSgwfGZ08wLtjU3Rl2zWouKkOWjbjMWg=;
        b=pyvvTa4RWERxcSYdS+r4P4SzbxgxyqUCfdAD+1IVPgaoSq2rKqPS7NC0rnizrv+pb1
         MiXPGRnGPzLHYYVxJ8ccstC/Sfo2GUv89qtk+G9VBg3h5okl62h8CgpC9TVRun9K5ccj
         81XhllQNSqFy1Te1hXJOZvisvmJOsuqw5bpsYGks8e2czz0DwUn+Hj9q71KtAjUclqo8
         FNtGHaRV9JcTTVdc+S+6rZFqjIQfx+8MT5nHO48NHIVKgR7v/zOEVZG8Jxf1hQQ+SF+5
         bkuuoqxEgLZoK7/0TpBRMhlfiA1ZIz9tmYg9lqrr6S1L2CGVlhuLmx/KsBVF36H7+l/n
         jJaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EnzJ0F54;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d24sor36881652ljj.24.2019.07.31.05.04.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 05:04:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EnzJ0F54;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=s4RPoNoetmDdSgwfGZ08wLtjU3Rl2zWouKkOWjbjMWg=;
        b=EnzJ0F54oAi0OX+GtgM+IK9898w+b4lTzvMaBjNRZOpQlW9SkJivV9CBK1He263F6C
         jVoK4t4SXObHIgZip1vxRSrvXk8iYH+MTUjZtp0yv8FnExJpGXN2FqaLWp+tay1BMfcR
         8MK7A2NfHrWBGRef9o1PnSD60zsjds10zk9lHfq6JROdLYdV70ulaBShPF7yGSrFln8S
         psto8j4HAmlFX6/aZe0qyt/GiphT0hnvT6dwGqRCKu4vh5GYuYrifqydVApYDnWBhDzu
         3Pfcks4w7GZ8yIXqlHZY+wTUJMTRqp2P6ysueSLTjlTFu8UEzESnRaE/vvkJMtDQYCyu
         fySQ==
X-Google-Smtp-Source: APXvYqzgMT2CPwJhuWzBpzLlg593pYgFccVPfTw85ro1+tK0oXAgWGp8XZ9qfVgWf8Lfeky8MTLVUA==
X-Received: by 2002:a2e:9c19:: with SMTP id s25mr41423681lji.188.1564574661794;
        Wed, 31 Jul 2019 05:04:21 -0700 (PDT)
Received: from pc636 ([37.212.215.48])
        by smtp.gmail.com with ESMTPSA id q2sm11607080lfj.25.2019.07.31.05.04.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 Jul 2019 05:04:19 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Wed, 31 Jul 2019 14:04:11 +0200
To: sathyanarayanan kuppuswamy <sathyanarayanan.kuppuswamy@linux.intel.com>
Cc: Uladzislau Rezki <urezki@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v1 1/1] mm/vmalloc.c: Fix percpu free VM area search
 criteria
Message-ID: <20190731120411.42ij4che425a5x3w@pc636>
References: <20190729232139.91131-1-sathyanarayanan.kuppuswamy@linux.intel.com>
 <20190730204643.tsxgc3n4adb63rlc@pc636>
 <d121eb22-01fd-c549-a6e8-9459c54d7ead@intel.com>
 <9fdd44c2-a10e-23f0-a71c-bf8f3e6fc384@linux.intel.com>
 <20190730223400.hzsyjrxng2s5gk4u@pc636>
 <63e48375-afa4-4ab6-240d-1633d7cc9ea4@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <63e48375-afa4-4ab6-240d-1633d7cc9ea4@linux.intel.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Sathyanarayanan.

> > Just to clarify, does it mean that on your setup you have only one area with the
> > 600000 size and 0xffff000000 offset?
> No, its 2 areas. with offset (0, ffff000000) and size (a00000, 600000).
> > 
Thank you for clarification, that makes sense to me. I also can reproduce
that issue, so i agree with your patch. Basically we can skip free VA
block(that can fit) examining previous one(my fault), instead of moving
base downwards and recheck an area that did not fit.

Reviewed-by: Uladzislau Rezki (Sony) <urezki@gmail.com>

Appreciate you for fixing it!

--
Vlad Rezki


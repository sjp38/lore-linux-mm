Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3A0EC74A52
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 08:23:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8852721655
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 08:23:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8852721655
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 256D56B0266; Thu, 11 Jul 2019 04:23:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 207DA8E00AB; Thu, 11 Jul 2019 04:23:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F7148E0032; Thu, 11 Jul 2019 04:23:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id CAA9D6B0266
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 04:23:19 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id u19so1313843wmj.0
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 01:23:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=t/qjY1W0ajqQxfo6AFYx0YD6CP414H8GLyhcPTKxRwU=;
        b=atPzaUtLbVtJCsJuSMnaMu1ioM02wKq1nc2UXiq6SPXUALOCOgZjekFvVURZyGjkIr
         C8uod2mjb9uLakP4hmw/tIF+lEIOcVq3yr56jWBtL0KRFx0QHIeXhqh4Y73up9bDwY04
         BlAmuOQZ+wfE77m/qLmvpreq1d8ckgBEmE5mFRVSOoIfwMo6xGDPl2s1AOL0g+J4alSt
         zLZiA2myzGEClqngISwGyocyAQM8c61boBGwQHnx/plpeR4H+uC46lWTKaxzkiT43DV6
         BMRWcD98yOoTHV5u/l64kIVkSLWm/exIvuSWowOluK5QFl9qGf/X7cYKOhb1JdXS3BnG
         g1dQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAW+Aro4g08+MlBt3X+L+/b904mSbn9DFVSuX9ICkdgzTEg4Ft78
	1sKa8ZT93UNuA4eCbV/AmSNJrzgn2MUxJ6S/4W9slAb0f69JHuaDzZiYNx7cV4toQfCttcng4x4
	yebS78muH53NBqQZtxVmhng3RuvUsNkjeZcPfw4NnLdSlVaRQpq7YhfQL8UQ++OsiCg==
X-Received: by 2002:a05:600c:214e:: with SMTP id v14mr2823234wml.96.1562833399294;
        Thu, 11 Jul 2019 01:23:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPtqtpYsRl3b2bieEdZDnNuRGWoL5oPhei7ZSnL4RXxMo5kJ1J4oWiXtKQZaRXtYmOk/se
X-Received: by 2002:a05:600c:214e:: with SMTP id v14mr2823149wml.96.1562833398403;
        Thu, 11 Jul 2019 01:23:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562833398; cv=none;
        d=google.com; s=arc-20160816;
        b=ezLgIYoqSmXHzR28rk6hS0QmFXY681JM6U3XV+gojggBqJOThVUqIsHGb56EZ4x9lh
         Vkdn9qgpT/1TvNHGS4+Hk/ubW53My5mmcmJSBLbZs0pk2iuftG55JrO/OhLnILJ8h9Xw
         hD15rqhTyacFVk1UEpduuNy59W201w0ZbDjojcLcAjLuRrN77NnTWbo37S8F3mEQJO+S
         CKhxfiYM0PR2WyqQJradqkXWfduCqsw/qjD9+yHYbpOVp692LuyW7tES3sTj4/QJVzjW
         BUtJjiSJrTqi2AKT66vA98TTjC2ETGAauV6BBDsoNYoKuWWCs0RKar5Si2Fj62aTYW93
         h23w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=t/qjY1W0ajqQxfo6AFYx0YD6CP414H8GLyhcPTKxRwU=;
        b=u/kWMGzR4iBuok8fbvmlFAe09VVixX7a7N0/bzihi/wqirkNFwqTrJWDbxgBbUlEcg
         XWzPvMbKd9w+/mrOjEf8qRdTDkgZXhFgLEEQTjSiyNCwJZFAlhZk6biXyr7Uudw4SSMQ
         yCHXsCqtEUQwQ2wfcvTe7EDrxSAqJUGwpAm392VDtKxlp8l1PzNR9o9kXn7y5kJIvIs0
         Nb8GeZcovg+/1HrhF2gig9m8yIhn9FRqYk8Hw+NAJL94lIlrKL2S8kuYdcutNMXmPcTg
         83a9GCAML0avkzv+BMjAAh4LrGG/B+KNt//i0hR53O4XLxcRBdOBycJY1IO1FgiHYViP
         5Evw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id e11si4676189wrt.289.2019.07.11.01.23.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jul 2019 01:23:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.55] (helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hlUMG-0001Fh-2N; Thu, 11 Jul 2019 10:23:16 +0200
Date: Thu, 11 Jul 2019 10:23:10 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Christopher Lameter <cl@linux.com>
cc: Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org, 
    linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, 
    linux-sh@vger.kernel.org
Subject: Re: [RFC PATCH] mm: remove quicklist page table caches
In-Reply-To: <0100016be006fbda-65d42038-d656-4d74-8b50-9c800afe4f96-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.21.1907111022400.1889@nanos.tec.linutronix.de>
References: <20190711030339.20892-1-npiggin@gmail.com> <0100016be006fbda-65d42038-d656-4d74-8b50-9c800afe4f96-000000@email.amazonses.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jul 2019, Christopher Lameter wrote:

> On Thu, 11 Jul 2019, Nicholas Piggin wrote:
> 
> > Remove page table allocator "quicklists". These have been around for a
> > long time, but have not got much traction in the last decade and are
> > only used on ia64 and sh architectures.
> 
> I also think its good to remove this code. Note sure though if IA64
> may still have a need of it. But then its not clear that the IA64 arch is
> still in use. Is it still maintained?

It's kept alive


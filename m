Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70542C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:46:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22A78217FA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:46:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22A78217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C18A66B0007; Thu, 18 Apr 2019 11:46:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC82B6B0008; Thu, 18 Apr 2019 11:46:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6A966B000A; Thu, 18 Apr 2019 11:46:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6758B6B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:46:35 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n5so1585803pgk.9
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:46:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vDW90YNKPN5NqFDIbEVZ/KkwPn3AGCw3gDCQIdNn3vg=;
        b=OV0CZGnhUPWelrTTsZVqWEB1pPPbGzu3oGloJI8MjPDMf19zUPhSkErBUVKXj0yTdk
         OxZjKEP3z12C7ZgNdq2Ij8q16PSXrJVlw2KKEW3zGquERNVfqoSt7YqJ0G8Kbx0i9Yf2
         SCr6Xu2FuRr+hfLuflsx8e6hMMzGBz1PWPL6p3nnC/eG07LZ26C23aeIlUeMFoSMb5v+
         j4GJL8A2kSvxcV+OeToer09UFXTc19y9kuK4JME8ag2mQ4Ub/t6+t9QEPNI5YtTCyFTX
         n4VGJg5mQHfuQkRngYk7KdVJHh9BWaIGcqTFwgG42ihEzmaPXc+NzfPwWB0bV8E+FTg7
         9RLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAVtPGuDIj8o3nu1adpr0YGcOuFYgOwtnriO7yDFcjHQVzNiHHq+
	lpGrcfStT1c3/2D6vzMJ5fFyEy/90r6iaq8nbh2Nt+6riL6MgZn4d9uDxALMnn+WxP51xxQ01ZW
	GdXL9Ud7fNPqIBVp+Olcq0ml+AH46ORnWbAxAu1NXRQoNIM5ljMSVazVZyMgGhZ8=
X-Received: by 2002:aa7:9a89:: with SMTP id w9mr89126168pfi.213.1555602395121;
        Thu, 18 Apr 2019 08:46:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxpnCEmtc03IYaX6s9DXwhyD6C7im20b0w6kKrw2tbTtfJ2OTF+4XDLCyezwZ+f4QwWkHq
X-Received: by 2002:aa7:9a89:: with SMTP id w9mr89126111pfi.213.1555602394442;
        Thu, 18 Apr 2019 08:46:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555602394; cv=none;
        d=google.com; s=arc-20160816;
        b=XZCjwhxA1Wp31Vqrc/ImIjUOZdSGH9E7S9xOacpNDOssXvEYg4t6XsAKUBOMxrzUgv
         ++MvO5UiS+YsmUblOhRYu64k37pBiHB99NBX35hh209ms9OUOBTosaxmO0mPWgXc1XGy
         DgeMmEHbyyCTsQRtwYDwjpLcC+vBY8cIe9gL7gF6SK9tayeBPujPQ1azoNGxVpPbViFN
         SgU8IvN9NnNU/9KcsazyAnPpKw2P4+LBhA4sj8QqVgjji3pc8s8FKrY0tedwXZtG8lyZ
         GjXlD5K2ff25rQ4wV2b5r+JeICGMbbx/Ei219D/2Jq8nEoAK4ap9bS+/SyNvzpxgd4Fv
         3FBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=vDW90YNKPN5NqFDIbEVZ/KkwPn3AGCw3gDCQIdNn3vg=;
        b=rFaJPUpJJwVSt3XqeLnH9fkw7e7CQqwmpgCZ+7NfM1ETWnLPWJMowNs9IwQWCEYNsN
         7T2AaImZ/YC0q4HYlZ8cP8iYtA1IvvxUdeDFHFd+YnZgObD65nNj16pB4009CN7zLPpR
         YFb1o6C8QnLkFB5lMACpNVvmaV0KF9jqwLLR3t5bpng4lk7ZBn78ppdIz03zzJAtolpN
         4fv7hJs5DjTmJw7M0oHoEoFbGP33dtf32v/Kk3Psh1zW6JvVXRdQpB00AWXtaZUXta47
         Kvi9fXHWog4OFAo2mcq7IKoYa3IlNZgbm1iRZmKEs+EHQs28dc1DUoFnPqIxQwpquNRw
         h5YQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g21si2921803pfg.286.2019.04.18.08.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 08:46:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 17C4B217D7;
	Thu, 18 Apr 2019 15:46:31 +0000 (UTC)
Date: Thu, 18 Apr 2019 11:46:29 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf
 <jpoimboe@redhat.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>,
 Alexander Potapenko <glider@google.com>, Alexey Dobriyan
 <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka
 Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes
 <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey
 Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, Mike
 Rapoport <rppt@linux.vnet.ibm.com>, Akinobu Mita <akinobu.mita@gmail.com>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski
 <m.szyprowski@samsung.com>, Johannes Thumshirn <jthumshirn@suse.de>, David
 Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>, Josef Bacik
 <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, David
 Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>,
 Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
 linux-arch@vger.kernel.org
Subject: Re: [patch V2 21/29] tracing: Use percpu stack trace buffer more
 intelligently
Message-ID: <20190418114629.023b63d7@gandalf.local.home>
In-Reply-To: <alpine.DEB.2.21.1904181743270.3174@nanos.tec.linutronix.de>
References: <20190418084119.056416939@linutronix.de>
	<20190418084254.999521114@linutronix.de>
	<20190418105334.5093528d@gandalf.local.home>
	<alpine.DEB.2.21.1904181743270.3174@nanos.tec.linutronix.de>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019 17:43:59 +0200 (CEST)
Thomas Gleixner <tglx@linutronix.de> wrote:

> On Thu, 18 Apr 2019, Steven Rostedt wrote:
> > On Thu, 18 Apr 2019 10:41:40 +0200
> > Thomas Gleixner <tglx@linutronix.de> wrote:  
> > > -static DEFINE_PER_CPU(struct ftrace_stack, ftrace_stack);
> > > +/* This allows 8 level nesting which is plenty */  
> > 
> > Can we make this 4 level nesting and increase the size? (I can see us
> > going more than 64 deep, kernel developers never cease to amaze me ;-)
> > That's all we need:
> > 
> >  Context: Normal, softirq, irq, NMI
> > 
> > Is there any other way to nest?  
> 
> Not that I know, but you are the tracer dude :)
>

There's other places I only test 4 deep, so it should be fine to limit
it to 4 then.

Thanks!

-- Steve


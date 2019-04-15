Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2451EC10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 16:58:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA3FC2075B
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 16:58:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZW0bL8k3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA3FC2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37ECE6B0003; Mon, 15 Apr 2019 12:58:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32BAE6B0006; Mon, 15 Apr 2019 12:58:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F3DC6B0007; Mon, 15 Apr 2019 12:58:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBFCA6B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 12:58:18 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e20so12216985pfn.8
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 09:58:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xoGvw0KP/qcN7+pEhAyZEUhWdqz/Hw7+wj7bzbRJTtM=;
        b=IQF3+NOruKbAqk13L1ggYF13NP18wsQVTCVZRuhnLJM4yLTrEcgguOBqZ8dRM1VLzY
         2qcNOIlcfrfgYjvMqvaFrPTn1G3l5scOqz83KQ2CCcnxsaptfXfxxGmjXRFbQMzL7nMF
         rT4/HHMWuUewyagAtf7ah2MqCsMTYUrGiSLklyIdIq6VMaa1Fm7kR1+QDpBt0iOJdwal
         eTy6Z9zz4mdHmtgQOHuvG8KaymwqUW+dyGsSIl0sLp8nne52+DIfs/GwMZDPdUkB+P2y
         6doP2v6UDKnnWAdSL7BEH2AFGWL3inZYTCFOcS3aHEhfPGYILyr7c5MqZKJzCxYzKr2x
         gLZQ==
X-Gm-Message-State: APjAAAVZU+nVRrD8+fgyH1s3q05EHH3wjDRKlrhyUp/70oour24A+YJ+
	zYfENcDR3pROFSc8Iv1PWahtTNG5OcbMoO1y2LRqpH75szyUrUbM8+KKz2qZ3BaGl8rmjN7MTx4
	HE4cQEOC4j6vyiYqFWXLxiAFC9kFdqnmeDl9gwzPxQauo5wFWL2uQL83620pX5Vpvtw==
X-Received: by 2002:a63:360e:: with SMTP id d14mr70276873pga.188.1555347498575;
        Mon, 15 Apr 2019 09:58:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4oS+8cZfmpgAZ3rL1Ei8jS+NkKO0OwztL58C5XGs3/PsONSiISlTn4Vlqaa4ZJiQiaUg8
X-Received: by 2002:a63:360e:: with SMTP id d14mr70276795pga.188.1555347497621;
        Mon, 15 Apr 2019 09:58:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555347497; cv=none;
        d=google.com; s=arc-20160816;
        b=iHASFlbHhA6DICnKj5jlqNi5EClIi3ItEHnl/PUayUMthJLUj7UEHJcOKDHvBv5xVr
         J4g9SlQvxpQvPdPrzc/7DfarJ0aQfy33XIRzxPObnfWHtLsYanqCLzVte1f2JZ4lbwsf
         +N+te1U0xnSDvhzL2ofzI3s5IotQsV6h5upjEMLCA6lO5lfFCzQRRw63KN4JDFX8cagD
         nyDEuzMnP2MCgICz7rBVUZgyWuxtJsa8Zxxx9lq6citPiDRCdgEMaU7+ZlcIpAnv8J4c
         9I3OfChEeRS2LR7vPhmKQrR0IYOa5kr3Oo5KUNripCFov7e6zn7LlBdW6AnKp0ziQf13
         h8Zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xoGvw0KP/qcN7+pEhAyZEUhWdqz/Hw7+wj7bzbRJTtM=;
        b=EMx5V6UL5i5nshWF8/Y5E3m/MntC5xfZ4boY23YGjlWluDoRnr4FGcIc/D5cfvdfqV
         2ZX8tQeXgjzNI9zA+1q5iX3aYeyIp1KXqgTBlWUJctaeGuGwj/4sOFGs5srdbvEGEMiF
         M0spFIFXJrP7JfYt5HEhaSFfDqWl/MQGXe5ro2IDT/OH2QCkofOfsfmHFqFY7U0SvtPG
         KfLl2D3yhi/glKp3pkDc2KggyiIO7voXiVeDFSbrwKZrtPpdyNCSn9xor6Ygf7Oj/xoy
         lOa6dRjklhkDbGO8TMzcdpKtS8R4gLc9p2ZbhN5yliOev+IjjFGlX4cSKVhfZn8SVHXF
         Zx7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ZW0bL8k3;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u1si21385603pfa.222.2019.04.15.09.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 09:58:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ZW0bL8k3;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CEFE7218FE
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 16:58:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555347497;
	bh=GYACN0p2wjGAv+jMcwdNtW95WFzRSOnlWbGcMv4b6po=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=ZW0bL8k3pZz3YEAIBJW65uPnMTFTzlmZeddbs0gxoFBms70VDJYWNkQWw/Qd95WXc
	 EKK8oaeIbAxDL2TvmhHswkHHX61RM2EKW9GXEOTLF4NtO6UPAtOj1V87Rs94ME8GJF
	 xd4VS6cXkg+Axq63gVkPr5PbnndKJrNrmT+0c1Hw=
Received: by mail-wr1-f51.google.com with SMTP id j9so22883664wrn.6
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 09:58:16 -0700 (PDT)
X-Received: by 2002:adf:c788:: with SMTP id l8mr47503243wrg.143.1555347495330;
 Mon, 15 Apr 2019 09:58:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190414155936.679808307@linutronix.de> <20190414160143.591255977@linutronix.de>
 <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com> <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 15 Apr 2019 09:58:04 -0700
X-Gmail-Original-Message-ID: <CALCETrXpmj=wp7Uq5r3kUE9iLEg2w6V=zsEL3sMHfc0HF1Yc+Q@mail.gmail.com>
Message-ID: <CALCETrXpmj=wp7Uq5r3kUE9iLEg2w6V=zsEL3sMHfc0HF1Yc+Q@mail.gmail.com>
Subject: Re: [patch V3 01/32] mm/slab: Fix broken stack trace storage
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	X86 ML <x86@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
	Sean Christopherson <sean.j.christopherson@intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Pekka Enberg <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 14, 2019 at 9:34 AM Thomas Gleixner <tglx@linutronix.de> wrote:
>
> On Sun, 14 Apr 2019, Andy Lutomirski wrote:
> > > +               struct stack_trace trace = {
> > > +                       .max_entries    = size - 4;
> > > +                       .entries        = addr;
> > > +                       .skip           = 3;
> > > +               };
> >
> > This looks correct, but I think that it would have been clearer if you
> > left the size -= 3 above.  You're still incrementing addr, but you're
> > not decrementing size, so they're out of sync and the resulting code
> > is hard to follow.
>
> What about the below?
>
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1480,10 +1480,12 @@ static void store_stackinfo(struct kmem_
>         *addr++ = 0x12345678;
>         *addr++ = caller;
>         *addr++ = smp_processor_id();
> +       size -= 3;
>  #ifdef CONFIG_STACKTRACE
>         {
>                 struct stack_trace trace = {
> -                       .max_entries    = size - 4;
> +                       /* Leave one for the end marker below */
> +                       .max_entries    = size - 1;
>                         .entries        = addr;
>                         .skip           = 3;
>                 };

Looks good to me.


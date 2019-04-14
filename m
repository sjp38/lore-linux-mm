Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2520C10F13
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 16:34:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A83AC2084D
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 16:34:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A83AC2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 296BE6B0005; Sun, 14 Apr 2019 12:34:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 243F16B0006; Sun, 14 Apr 2019 12:34:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 135696B0007; Sun, 14 Apr 2019 12:34:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB4066B0005
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 12:34:21 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id h14so13010376wrs.14
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 09:34:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=y7KATPpGGGqpt7NNbOtmRFMWonTq8YaWO+dk+2RuBVk=;
        b=UoP7xk5QxjNfXqQtrQyH2LHB+yrCZDrUHZNR6zECWOrU7cTKVcBF4s2epx+x0PNy31
         zEowciwEEJfqhZALDGEWjwTeDDDmxBJzzPjqcxurGdbSLcj0KnWpMpywgvVjaksNV9Ch
         lPPt072aE7Ueo7aIT/AggmOpiHUkYwRwyZDl988LnHpcmpCRSvB+W5E+Li82fTbZ/Rum
         c/c0CEblQqYW498nmTgi+LuDrng7euYFwZMDYjVEWP48xYz8gmbelfz1cd8lrUKo4tHd
         1jk3e/O/8m9wvqMJ2NNFnfXTuUYQsDkPp/jd3U8JuEZNfTFG8F2sVxxGX9+MU+gs/o70
         IeXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAX12+Z2jg0MXhQsBSrUNK5yzE7AWeraf965smtMVi5/X+by8NYn
	2SGrzA1BYJKrmVUphSTMr2ZoLcXE/26fbbrdaGc4nqtyGv9Azgyuhd9iHMPRBf7CdCASTOXOCkl
	Kyf7Een9AgNHUxaC0FSCOBQXA3VtI+5/0WDff+Iu6beJp2cCR2uwJdlr8SG1oLnZgbQ==
X-Received: by 2002:a5d:6b10:: with SMTP id v16mr46649260wrw.294.1555259661272;
        Sun, 14 Apr 2019 09:34:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxa48V1zG4nnF6QbX2KV3/OBx2T5OOwcmZyZ1IvD0JnxvX7izPTap3pYHxvxAhYkdRUWbZc
X-Received: by 2002:a5d:6b10:: with SMTP id v16mr46649230wrw.294.1555259660470;
        Sun, 14 Apr 2019 09:34:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555259660; cv=none;
        d=google.com; s=arc-20160816;
        b=dqsREX+6sfn4k5fE6xdmfVPRewNCfZQOMbT6PNqktdBacYGrTTLBTv60Hm2kJGite2
         zsqk8U8v14p1HTr9hkes5EUL2pwh1BaINWkvTQJU5TS7Nhm432i7Q7d0js5VLFCnimQ2
         FXRChOsiLnDqB/pK/wu0Vj9shfyHi+VS4a+CABLcz31JDdpIKEy0VvYPKzYj5qP2w1KY
         f3XkoNuZ6PrU7R0xKguV33HTwaUZaAjm62rP6xYJ0Wd2Ha3qh6XZoNvp6jV6cfLMdOMi
         QgB+/6TiTsvTVl0A7NCunRkAxZzn8GdHd837nAOjhwdAThKWNmPNme2ZkY3iLR1AEMPJ
         5QKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=y7KATPpGGGqpt7NNbOtmRFMWonTq8YaWO+dk+2RuBVk=;
        b=ReuVcYiwkjpUplW84/6aP2VxKqujHLTqFw97OGZfJzHhKJVYcpcHgGpKd6PGIXAh7W
         KqyFw1VA20UCHMEMB7rozf++Co/iWhYf6fbKcU0kJRab46gh69mICQ0BmRxWqORKGTBy
         RpHEsLhqMk9/bY3eixMVg8izxQiue0vvdgpTFr1BdE43CcTzJfVoINTcuMdNLQxBGrb/
         Rgx7ET62yILsiS1C3ITINs1S1cEJdECgTG0qhlYuI7vOfQgiaPs3uUxquTxyKXs8XdaV
         iY3zIJc3v1Fvm0ldFkFXF0v+VyZodBO9fqqoLXt/SE+kcy7lS8Y0atvuEQx+3gF78R6F
         2leg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c8si9080148wml.44.2019.04.14.09.34.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 14 Apr 2019 09:34:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hFi59-0003i9-HO; Sun, 14 Apr 2019 18:34:15 +0200
Date: Sun, 14 Apr 2019 18:34:14 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Andy Lutomirski <luto@kernel.org>
cc: LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, 
    Josh Poimboeuf <jpoimboe@redhat.com>, 
    Sean Christopherson <sean.j.christopherson@intel.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>
Subject: Re: [patch V3 01/32] mm/slab: Fix broken stack trace storage
In-Reply-To: <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de>
References: <20190414155936.679808307@linutronix.de> <20190414160143.591255977@linutronix.de> <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com>
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

On Sun, 14 Apr 2019, Andy Lutomirski wrote:
> > +               struct stack_trace trace = {
> > +                       .max_entries    = size - 4;
> > +                       .entries        = addr;
> > +                       .skip           = 3;
> > +               };
> 
> This looks correct, but I think that it would have been clearer if you
> left the size -= 3 above.  You're still incrementing addr, but you're
> not decrementing size, so they're out of sync and the resulting code
> is hard to follow.

What about the below?

--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1480,10 +1480,12 @@ static void store_stackinfo(struct kmem_
 	*addr++ = 0x12345678;
 	*addr++ = caller;
 	*addr++ = smp_processor_id();
+	size -= 3;
 #ifdef CONFIG_STACKTRACE
 	{
 		struct stack_trace trace = {
-			.max_entries	= size - 4;
+			/* Leave one for the end marker below */
+			.max_entries	= size - 1;
 			.entries	= addr;
 			.skip		= 3;
 		};


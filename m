Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97CBDC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:53:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AE2A2183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:53:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AE2A2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E62F46B0005; Thu, 18 Apr 2019 10:53:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E12916B0006; Thu, 18 Apr 2019 10:53:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB3C66B0007; Thu, 18 Apr 2019 10:53:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9107B6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 10:53:40 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 18so1490200pgx.11
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:53:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=l9iiOHhrYHSRknLsyKFVdUHe2yDzQ8P/sJedBWVLSKo=;
        b=giZ9vcbOULOvCvA1c2ebI6XwEFm6wLZ/CGbwIKhVUnu2CoZWbqgTCLDWkjMY4/eOHg
         CSn+i9PENXzeANcTQfMej0KUzhNmx4ctvgqhZ7olaLrZ11YrCQAMZrqFcsRnjC+OXdGz
         3c5oeP0jKXE3aHZHJA1OqrTGH77TkmfM64iMaaEzRe4dLuhUpNXrojZpl8dq4mom0CHd
         HE0zcaiP8eedHIqw8BjyU1hgH5912tTkq0obnjVNwAdQ03yQqybBRBCjdKjCsjPjetOr
         RHk+CqBoadj5S0rNXthJ925rOETFdqK0rKSYt03WDQL+XzbDQsZeUi+aHDBk24HdS+lT
         oVjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAXW1wo9CD7rEbURFG5vLM/5MYMOw80PBpGU44C6ULalCg5w/6GO
	q/VELZEjWyKlacD79tE/QmXhnyhdbUUVXjH+4akUbD+UhZtXHsfWOAzHKPi6e8ztdnsrK/Ybo1o
	RLbvkopWjFHvmOaRBJ8rJpwabQScZb11enm+GKCHaZGANoYirhcIwUDBoiXRtlmk=
X-Received: by 2002:aa7:91d6:: with SMTP id z22mr6824016pfa.242.1555599220256;
        Thu, 18 Apr 2019 07:53:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1743J3Wdqz8Ta12vmHpPABVLimbGoGC4e8teyspSeFdyqMSZDu6CDW8HfFP75LweaZC52
X-Received: by 2002:aa7:91d6:: with SMTP id z22mr6823963pfa.242.1555599219594;
        Thu, 18 Apr 2019 07:53:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555599219; cv=none;
        d=google.com; s=arc-20160816;
        b=X9o/uEcts43LaIc8dW9q3XBxKDCceFuEkMItwguY203U6dNSMdpQopAHkYKG4VB0Uf
         CFJ5uVQ9GqkKceS+z5C1pbyjayJw8lJS8G7t5bYPg1g9bIAXWltv15z8w3G54Oc85pLE
         kOPAvzRIH3cS44kWv59RmJTDrINnQHXfx73T6z+i+sOqLhMShuBg66zZVZNr3pmXV1RZ
         DrhuHAYDNm+cfO2zz+SvKlWrXzy6P3eMWuR2yHi3sWAYeU0ZvobEt8KeJp30p2VIS/I4
         Yub1Ry11ItUdULAUiMrt4FpF/zjA8QQRMXZB/7MUsNbkiXBpui9lzrPabE4UAuhMiMdB
         G5Bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=l9iiOHhrYHSRknLsyKFVdUHe2yDzQ8P/sJedBWVLSKo=;
        b=X+w0M8VlRImZjfeCodYLCni0Izas+/0+LHIKkAxmlC7cZuXojmHt3OBlBsP93a3IV4
         O5r93pVc2q6KP70Qgdnu/BuW9JYyM0TY+Zm1UYAAKIJhZxmogpoKAk4XEGuqFo7+IkDf
         AGv+cneYNHWZ7dEW65uwVfchLZ1pmh2MpCsEkbCpEYLSeAp1eUf7RojLFrHwniFcLzPF
         Eb8ttXkqHqESq/wvfhQzz8N0THSwvUfzCVFVzEsQEFZ5TelqFzGQ3KLDK+d3NBgmai/F
         3uFwyYvkC5kkEPKq9su6QpC1DIjxqf+7mG3JVhVtkOEPUsjoUflQbuZwHPhQizrH+0gT
         OAaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id cu15si2432130plb.83.2019.04.18.07.53.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 07:53:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=+lpg=su=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=+LPG=SU=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 35831206B6;
	Thu, 18 Apr 2019 14:53:36 +0000 (UTC)
Date: Thu, 18 Apr 2019 10:53:34 -0400
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
Message-ID: <20190418105334.5093528d@gandalf.local.home>
In-Reply-To: <20190418084254.999521114@linutronix.de>
References: <20190418084119.056416939@linutronix.de>
	<20190418084254.999521114@linutronix.de>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019 10:41:40 +0200
Thomas Gleixner <tglx@linutronix.de> wrote:

> The per cpu stack trace buffer usage pattern is odd at best. The buffer has
> place for 512 stack trace entries on 64-bit and 1024 on 32-bit. When
> interrupts or exceptions nest after the per cpu buffer was acquired the
> stacktrace length is hardcoded to 8 entries. 512/1024 stack trace entries
> in kernel stacks are unrealistic so the buffer is a complete waste.
> 
> Split the buffer into chunks of 64 stack entries which is plenty. This
> allows nesting contexts (interrupts, exceptions) to utilize the cpu buffer
> for stack retrieval and avoids the fixed length allocation along with the
> conditional execution pathes.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> ---
>  kernel/trace/trace.c |   77 +++++++++++++++++++++++++--------------------------
>  1 file changed, 39 insertions(+), 38 deletions(-)
> 
> --- a/kernel/trace/trace.c
> +++ b/kernel/trace/trace.c
> @@ -2749,12 +2749,21 @@ trace_function(struct trace_array *tr,
>  
>  #ifdef CONFIG_STACKTRACE
>  
> -#define FTRACE_STACK_MAX_ENTRIES (PAGE_SIZE / sizeof(unsigned long))
> +/* 64 entries for kernel stacks are plenty */
> +#define FTRACE_KSTACK_ENTRIES	64
> +
>  struct ftrace_stack {
> -	unsigned long		calls[FTRACE_STACK_MAX_ENTRIES];
> +	unsigned long		calls[FTRACE_KSTACK_ENTRIES];
>  };
>  
> -static DEFINE_PER_CPU(struct ftrace_stack, ftrace_stack);
> +/* This allows 8 level nesting which is plenty */

Can we make this 4 level nesting and increase the size? (I can see us
going more than 64 deep, kernel developers never cease to amaze me ;-)
That's all we need:

 Context: Normal, softirq, irq, NMI

Is there any other way to nest?

-- Steve

> +#define FTRACE_KSTACK_NESTING	(PAGE_SIZE / sizeof(struct ftrace_stack))
> +
> +struct ftrace_stacks {
> +	struct ftrace_stack	stacks[FTRACE_KSTACK_NESTING];
> +};
> +
> +static DEFINE_PER_CPU(struct ftrace_stacks, ftrace_stacks);
>  static DEFINE_PER_CPU(int, ftrace_stack_reserve);
>  
> 


Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 516CE28001C
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 03:45:39 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id hl2so458666igb.16
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 00:45:39 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0221.hostedemail.com. [216.40.44.221])
        by mx.google.com with ESMTP id d7si14374612igg.40.2014.10.31.00.45.38
        for <linux-mm@kvack.org>;
        Fri, 31 Oct 2014 00:45:38 -0700 (PDT)
Message-ID: <1414741535.8928.2.camel@perches.com>
Subject: Re: [RFC] arm:remove clear_thread_flag(TIF_UPROBE)
From: Joe Perches <joe@perches.com>
Date: Fri, 31 Oct 2014 00:45:35 -0700
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D1827B@CNBJMBX05.corpusers.net>
References: <1414392371.8884.2.camel@perches.com>
	 <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
	 <35FD53F367049845BC99AC72306C23D103E010D1825F@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18260@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
	 <20141030120127.GC32589@arm.com>
	 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
	 <20141030135749.GE32589@arm.com>
	 <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18273@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18275@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D1827B@CNBJMBX05.corpusers.net>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Will Deacon' <will.deacon@arm.com>, 'Ard Biesheuvel' <ard.biesheuvel@linaro.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Fri, 2014-10-31 at 15:40 +0800, Wang, Yalin wrote:
> This patch remove clear_thread_flag(TIF_UPROBE) in do_work_pending(),
> because uprobe_notify_resume() have do this.
[]
> diff --git a/arch/arm/kernel/signal.c b/arch/arm/kernel/signal.c
[]
> @@ -591,10 +591,9 @@ do_work_pending(struct pt_regs *regs, unsigned int thread_flags, int syscall)
>  					return restart;
>  				}
>  				syscall = 0;
> -			} else if (thread_flags & _TIF_UPROBE) {
> -				clear_thread_flag(TIF_UPROBE);
> +			} else if (thread_flags & _TIF_UPROBE)
>  				uprobe_notify_resume(regs);
> -			} else {
> +			else {
>  				clear_thread_flag(TIF_NOTIFY_RESUME);
>  				tracehook_notify_resume(regs);
>  			}

Please keep the braces.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

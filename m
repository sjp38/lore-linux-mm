Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 427656B0253
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 12:59:00 -0500 (EST)
Received: by padhx2 with SMTP id hx2so16905783pad.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 09:59:00 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u16si43535438pbs.235.2015.11.03.09.58.59
        for <linux-mm@kvack.org>;
        Tue, 03 Nov 2015 09:58:59 -0800 (PST)
Message-ID: <5638F5B9.3040404@arm.com>
Date: Tue, 03 Nov 2015 17:58:17 +0000
From: James Morse <james.morse@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 2/3] percpu: add PERCPU_ATOM_SIZE for a generic percpu
 area setup
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com> <1446363977-23656-3-git-send-email-jungseoklee85@gmail.com> <alpine.DEB.2.20.1511021008580.27740@east.gentwo.org> <20151102162236.GB7637@e104818-lin.cambridge.arm.com> <F4C06691-60EF-45FA-9AD7-9FBF8F1960AB@gmail.com>
In-Reply-To: <F4C06691-60EF-45FA-9AD7-9FBF8F1960AB@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jungseok Lee <jungseoklee85@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>, mark.rutland@arm.com, takahiro.akashi@linaro.org, barami97@gmail.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, linux-arm-kernel@lists.infradead.org

Hi Jungseok,

On 03/11/15 13:49, Jungseok Lee wrote:
> Additionally, I've been thinking of do_softirq_own_stack() which is your
> another comment [3]. Recently, I've realized there is possibility that
> I misunderstood your intention. Did you mean that irq_handler hook is not
> enough? Should do_softirq_own_stack() be implemented together?

I've been putting together a version to illustrate this, I aim to post it
before the end of this week...


Thanks,

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

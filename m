Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id A6FCD6B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 11:48:19 -0500 (EST)
Received: by iofz202 with SMTP id z202so149528848iof.2
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 08:48:19 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id c139si17908619ioe.115.2015.11.02.08.48.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 02 Nov 2015 08:48:19 -0800 (PST)
Date: Mon, 2 Nov 2015 10:48:17 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v6 2/3] percpu: add PERCPU_ATOM_SIZE for a generic percpu
 area setup
In-Reply-To: <20151102162236.GB7637@e104818-lin.cambridge.arm.com>
Message-ID: <alpine.DEB.2.20.1511021047420.28255@east.gentwo.org>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com> <1446363977-23656-3-git-send-email-jungseoklee85@gmail.com> <alpine.DEB.2.20.1511021008580.27740@east.gentwo.org> <20151102162236.GB7637@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Jungseok Lee <jungseoklee85@gmail.com>, mark.rutland@arm.com, takahiro.akashi@linaro.org, barami97@gmail.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, james.morse@arm.com, tj@kernel.org, linux-arm-kernel@lists.infradead.org

On Mon, 2 Nov 2015, Catalin Marinas wrote:

> I haven't looked at the patch 3/3 in detail but I'm pretty sure I'll NAK
> the approach (and the definition of PERCPU_ATOM_SIZE), therefore
> rendering this patch unnecessary. IIUC, this is used to enforce some
> alignment of the per-CPU IRQ stack to be able to check whether the
> current stack is process or IRQ on exception entry. But there are other,
> less intrusive ways to achieve the same (e.g. x86).

The percpu allocator allows the specification of alignment requirements.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

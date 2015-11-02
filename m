Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id C39196B0253
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 11:10:24 -0500 (EST)
Received: by iody8 with SMTP id y8so148035670iod.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 08:10:24 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id q6si12597621igr.92.2015.11.02.08.10.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 02 Nov 2015 08:10:24 -0800 (PST)
Date: Mon, 2 Nov 2015 10:10:23 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v6 2/3] percpu: add PERCPU_ATOM_SIZE for a generic percpu
 area setup
In-Reply-To: <1446363977-23656-3-git-send-email-jungseoklee85@gmail.com>
Message-ID: <alpine.DEB.2.20.1511021008580.27740@east.gentwo.org>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com> <1446363977-23656-3-git-send-email-jungseoklee85@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jungseok Lee <jungseoklee85@gmail.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, tj@kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, james.morse@arm.com, takahiro.akashi@linaro.org, mark.rutland@arm.com, barami97@gmail.com, linux-kernel@vger.kernel.org

On Sun, 1 Nov 2015, Jungseok Lee wrote:

> There is no room to adjust 'atom_size' now when a generic percpu area
> is used. It would be redundant to write down an architecture-specific
> setup_per_cpu_areas() in order to only change the 'atom_size'. Thus,
> this patch adds a new definition, PERCPU_ATOM_SIZE, which is PAGE_SIZE
> by default. The value could be updated if needed by architecture.

What is atom_size? Why would you want a difference allocation size here?
The percpu area is virtually mapped regardless. So you will have
contiguous addresses even without atom_size.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

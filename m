Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 754256B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 11:08:48 -0500 (EST)
Received: by igpw7 with SMTP id w7so51399163igp.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 08:08:48 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id l133si17765030iol.93.2015.11.02.08.08.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 02 Nov 2015 08:08:47 -0800 (PST)
Date: Mon, 2 Nov 2015 10:08:46 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v6 1/3] percpu: remove PERCPU_ENOUGH_ROOM which is stale
 definition
In-Reply-To: <1446363977-23656-2-git-send-email-jungseoklee85@gmail.com>
Message-ID: <alpine.DEB.2.20.1511021007400.27740@east.gentwo.org>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com> <1446363977-23656-2-git-send-email-jungseoklee85@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jungseok Lee <jungseoklee85@gmail.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, tj@kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, james.morse@arm.com, takahiro.akashi@linaro.org, mark.rutland@arm.com, barami97@gmail.com, linux-kernel@vger.kernel.org

On Sun, 1 Nov 2015, Jungseok Lee wrote:

> As pure cleanup, this patch removes PERCPU_ENOUGH_ROOM which is not
> used any more. That is, no code refers to the definition.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

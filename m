Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id BB6116B0254
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 10:01:03 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id ig19so19534902igb.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 07:01:03 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id i198si5142298ioi.75.2016.03.08.07.00.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 07:00:59 -0800 (PST)
Date: Tue, 8 Mar 2016 09:00:57 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: slub: Ensure that slab_unlock() is atomic
In-Reply-To: <1457447457-25878-1-git-send-email-vgupta@synopsys.com>
Message-ID: <alpine.DEB.2.20.1603080857360.4047@east.gentwo.org>
References: <1457447457-25878-1-git-send-email-vgupta@synopsys.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Noam Camus <noamc@ezchip.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org

On Tue, 8 Mar 2016, Vineet Gupta wrote:

> This in turn happened because slab_unlock() doesn't serialize properly
> (doesn't use atomic clear) with a concurrent running
> slab_lock()->test_and_set_bit()

This is intentional because of the increased latency of atomic
instructions. Why would the unlock need to be atomic? This patch will
cause regressions.

Guess this is an architecture specific issue of modified
cachelines not becoming visible to other processors?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id E7FC66B0071
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 12:22:17 -0500 (EST)
Date: Mon, 30 Jan 2012 11:22:14 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] percpu: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
In-Reply-To: <20120130171558.GB3355@google.com>
Message-ID: <alpine.DEB.2.00.1201301121330.28693@router.home>
References: <1327912654-8738-1-git-send-email-dmitry.antipov@linaro.org> <20120130171558.GB3355@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Dmitry Antipov <dmitry.antipov@linaro.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-dev@lists.linaro.org

On Mon, 30 Jan 2012, Tejun Heo wrote:

> Percpu pointers are in a different address space and using
> ZERO_SIZE_PTR directly will trigger sparse address space warning.
> Also, I'm not entirely sure whether 16 is guaranteed to be unused in
> percpu address space (maybe it is but I don't think we have anything
> enforcing that).

We are already checking for NULL on free. So there is a presumption that
these numbers are unused.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

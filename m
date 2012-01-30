Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 687166B0074
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 12:35:32 -0500 (EST)
Date: Mon, 30 Jan 2012 11:35:29 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] percpu: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
In-Reply-To: <20120130173311.GE3355@google.com>
Message-ID: <alpine.DEB.2.00.1201301134090.28693@router.home>
References: <1327912654-8738-1-git-send-email-dmitry.antipov@linaro.org> <20120130171558.GB3355@google.com> <20120130171919.GC3355@google.com> <alpine.DEB.2.00.1201301122410.28693@router.home> <20120130173311.GE3355@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Dmitry Antipov <dmitry.antipov@linaro.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-dev@lists.linaro.org

On Mon, 30 Jan 2012, Tejun Heo wrote:

> I'm pretty sure it never gives out NULL for a dynamic allocation.  The
> base might be mapped to zero but we're guaranteed to have some static
> percpu areas there and IIRC the percpu addresses aren't supposed to
> wrap.

True but there is a check for a NULL pointer on free. So a NULL pointer
currently has the semantics of being an unallocated per cpu structure.
If the allocator returns NULL by accident then we cannot free the per cpu
allocation anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

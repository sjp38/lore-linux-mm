Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 9EF0C6B005C
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 11:15:21 -0500 (EST)
Date: Mon, 30 Jan 2012 10:15:18 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] percpu: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
In-Reply-To: <1327912654-8738-1-git-send-email-dmitry.antipov@linaro.org>
Message-ID: <alpine.DEB.2.00.1201301006140.28693@router.home>
References: <1327912654-8738-1-git-send-email-dmitry.antipov@linaro.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Antipov <dmitry.antipov@linaro.org>
Cc: Tejun Heo <tj@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-dev@lists.linaro.org

On Mon, 30 Jan 2012, Dmitry Antipov wrote:

> Fix pcpu_alloc() to return ZERO_SIZE_PTR if requested size is 0;
> fix free_percpu() to check passed pointer with ZERO_OR_NULL_PTR.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

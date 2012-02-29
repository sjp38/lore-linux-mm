Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id A55576B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 01:51:56 -0500 (EST)
Received: by bkty12 with SMTP id y12so7382411bkt.14
        for <linux-mm@kvack.org>; Tue, 28 Feb 2012 22:51:55 -0800 (PST)
Message-ID: <4F4DCB59.5060205@linaro.org>
Date: Wed, 29 Feb 2012 10:53:13 +0400
From: Dmitry Antipov <dmitry.antipov@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] vmalloc: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
References: <1330421640-5137-1-git-send-email-dmitry.antipov@linaro.org> <20120228094415.GA2868@mwanda> <4F4CC19D.9040608@linaro.org> <20120228133037.GG2817@mwanda>
In-Reply-To: <20120228133037.GG2817@mwanda>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Rusty Russell <rusty.russell@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-dev@lists.linaro.org, patches@linaro.org

On 02/28/2012 05:30 PM, Dan Carpenter wrote:

> Could you include that in the changelog when the final version is
> ready?

What changelog you're saying about?

Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

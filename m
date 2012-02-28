Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id C368A6B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 06:58:09 -0500 (EST)
Received: by bkty12 with SMTP id y12so6228888bkt.14
        for <linux-mm@kvack.org>; Tue, 28 Feb 2012 03:58:08 -0800 (PST)
Message-ID: <4F4CC19D.9040608@linaro.org>
Date: Tue, 28 Feb 2012 15:59:25 +0400
From: Dmitry Antipov <dmitry.antipov@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] vmalloc: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
References: <1330421640-5137-1-git-send-email-dmitry.antipov@linaro.org> <20120228094415.GA2868@mwanda>
In-Reply-To: <20120228094415.GA2868@mwanda>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Rusty Russell <rusty.russell@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-dev@lists.linaro.org, patches@linaro.org

On 02/28/2012 01:44 PM, Dan Carpenter wrote:
> On Tue, Feb 28, 2012 at 01:33:59PM +0400, Dmitry Antipov wrote:
>>   - Fix vmap() to return ZERO_SIZE_PTR if 0 pages are requested;
>>   - fix __vmalloc_node_range() to return ZERO_SIZE_PTR if 0 bytes
>>     are requested;
>>   - fix __vunmap() to check passed pointer with ZERO_OR_NULL_PTR.
>>
>
> Why?

1) it was requested by the subsystem (co?)maintainer, see http://lkml.org/lkml/2012/1/27/475;
2) this looks to be a convenient way to trace/debug zero-size allocation errors (although
    I don't advocate it as a best way).

Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 4A0E96B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 03:29:47 -0500 (EST)
Received: by obbta7 with SMTP id ta7so10320988obb.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 00:29:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F4DCB59.5060205@linaro.org>
References: <1330421640-5137-1-git-send-email-dmitry.antipov@linaro.org>
	<20120228094415.GA2868@mwanda>
	<4F4CC19D.9040608@linaro.org>
	<20120228133037.GG2817@mwanda>
	<4F4DCB59.5060205@linaro.org>
Date: Wed, 29 Feb 2012 10:29:46 +0200
Message-ID: <CAP245DWOCZx6Nd3a9LZCnHoTKMUmYWtkBwyM3vn9htmQ-edibA@mail.gmail.com>
Subject: Re: [PATCH 1/2] vmalloc: use ZERO_SIZE_PTR / ZERO_OR_NULL_PTR
From: Amit Kucheria <amit.kucheria@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Antipov <dmitry.antipov@linaro.org>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, linaro-dev@lists.linaro.org, patches@linaro.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rusty Russell <rusty.russell@linaro.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Feb 29, 2012 at 8:53 AM, Dmitry Antipov
<dmitry.antipov@linaro.org> wrote:
> On 02/28/2012 05:30 PM, Dan Carpenter wrote:
>
>> Could you include that in the changelog when the final version is
>> ready?
>
>
> What changelog you're saying about?

Dmitry, he means your commit log message.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

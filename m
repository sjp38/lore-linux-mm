Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A59B36B0012
	for <linux-mm@kvack.org>; Fri,  6 May 2011 20:03:55 -0400 (EDT)
Received: by gwaa12 with SMTP id a12so1865717gwa.14
        for <linux-mm@kvack.org>; Fri, 06 May 2011 17:03:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1105061355020.5832@router.home>
References: <BANLkTi=Jdxu7am8-jhJbT0t-uhNmW4zWhw@mail.gmail.com>
	<alpine.DEB.2.00.1105061355020.5832@router.home>
Date: Sat, 7 May 2011 03:03:53 +0300
Message-ID: <BANLkTinAw7gxg8Q6D8pK3_pnPpidQa2-bA@mail.gmail.com>
Subject: Re: [PATCH] slub: slub_def.h: needs additional check for "index"
From: Maxin John <maxin.john@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Fri, May 6, 2011 at 9:56 PM, Christoph Lameter <cl@linux.com> wrote:
> The value passed to kmalloc_slab is tested before the result is used.
> kmalloc_slab() only returns -1 for values > 4MB.
>
> The size of the object is checked against SLUB_MAX size which is
> significantly smaller than 4MB. 8kb by default.
>
> So kmalloc_slab() cannot return -1 if the parameter is checked first.

Thank you very much for pointing it out. I think it's a lot more clear
for me now.

Best Regards,
Maxin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

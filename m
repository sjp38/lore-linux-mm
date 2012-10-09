Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 08F226B005D
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 11:25:44 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so14164476ied.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2012 08:25:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <507371DA.9080309@samsung.com>
References: <CAH+eYFCJTtF+FeqKs_ho5yyX0tkUBoaa-yfsd1rVshcQ5Xxp=A@mail.gmail.com>
 <507371DA.9080309@samsung.com>
From: Rabin Vincent <rabin@rab.in>
Date: Tue, 9 Oct 2012 17:25:03 +0200
Message-ID: <CAH+eYFDK=C4=e5D00=TM=rv+zzE1rEuQ_=97A5T0z6pORTLMpA@mail.gmail.com>
Subject: Re: CMA and zone watermarks
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Marek, Minchan,

2012/10/9 Marek Szyprowski <m.szyprowski@samsung.com>:
> Could You run your test with latest linux-next kernel? There have been some
> patches merged to akpm tree which should fix accounting for free and free
> cma pages. I hope it should fix this issue.

I've tested with the mentioned patches (which seem to have also reached
Linus' tree today) and they appear to resolve the problem.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

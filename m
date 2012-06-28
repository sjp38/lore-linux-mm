Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 0797D6B0069
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 02:54:56 -0400 (EDT)
From: "Kim, Jong-Sung" <neidhard.kim@lge.com>
References: <1338880312-17561-1-git-send-email-minchan@kernel.org> <025701cd457e$d5065410$7f12fc30$@lge.com> <20120627160220.GA2310@linaro.org> <00e801cd54f0$eb8a3540$c29e9fc0$@lge.com> <alpine.LFD.2.02.1206280223250.31003@xanadu.home>
In-Reply-To: <alpine.LFD.2.02.1206280223250.31003@xanadu.home>
Subject: RE: [PATCH] [RESEND] arm: limit memblock base address for early_pte_alloc
Date: Thu, 28 Jun 2012 15:54:49 +0900
Message-ID: <010e01cd54fa$e9c93fd0$bd5bbf70$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Nicolas Pitre' <nicolas.pitre@linaro.org>
Cc: 'Dave Martin' <dave.martin@linaro.org>, 'Minchan Kim' <minchan@kernel.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Catalin Marinas' <catalin.marinas@arm.com>, 'Chanho Min' <chanho.min@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

> From: Nicolas Pitre [mailto:nicolas.pitre@linaro.org]
> Sent: Thursday, June 28, 2012 3:26 PM
> 
> On Thu, 28 Jun 2012, Kim, Jong-Sung wrote:
> 
> > Thank you for your comment, Dave! It was not that sophisticated
> > choice, but I thought that normal embedded system trying to reduce the
> > BOM would have a big-enough first memblock memory region. However
> > you're right. There can be exceptional systems. Then, how do you think
> about following manner:
> [...]
> 
> This still has some possibilities for failure.
> 
Can you kindly describe the possible failure path?

> Please have a look at the two patches I've posted to fix this in a better
> way.
> 
I'm setting up for your elegant patches. ;-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 582306B006C
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 13:32:05 -0400 (EDT)
Message-ID: <50463A93.1080108@xenotime.net>
Date: Tue, 04 Sep 2012 10:29:55 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
Subject: Re: linux-next: Tree for Sept 4 (cma)
References: <20120904171330.f6b0a922a754ba0f3acc123b@canb.auug.org.au>
In-Reply-To: <20120904171330.f6b0a922a754ba0f3acc123b@canb.auug.org.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>

On 09/04/2012 12:13 AM, Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20120824:
> 



drivers/base/dma-contiguous.c:351:3: error: expected ';' before '}' token


		} else if (ret != -EBUSY) {
>>>			break
		}


-- 

~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

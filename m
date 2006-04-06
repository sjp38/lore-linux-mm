Date: Wed, 5 Apr 2006 19:43:44 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Respin: [PATCH] mm: limit lowmem_reserve
Message-Id: <20060405194344.1915b57a.akpm@osdl.org>
In-Reply-To: <200604061129.41658.kernel@kolivas.org>
References: <200604021401.13331.kernel@kolivas.org>
	<200604041235.59876.kernel@kolivas.org>
	<200604061110.35789.kernel@kolivas.org>
	<200604061129.41658.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-kernel@vger.kernel.org, ck@vds.kolivas.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Con Kolivas <kernel@kolivas.org> wrote:
>
> It is possible with a low enough lowmem_reserve ratio to make
>  zone_watermark_ok fail repeatedly if the lower_zone is small enough.

Is that actually a problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

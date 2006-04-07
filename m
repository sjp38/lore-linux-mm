From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: limit lowmem_reserve
Date: Fri, 7 Apr 2006 19:02:15 +1000
References: <200604021401.13331.kernel@kolivas.org> <200604061110.35789.kernel@kolivas.org> <443605E1.7060203@yahoo.com.au>
In-Reply-To: <443605E1.7060203@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604071902.16011.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, ck@vds.kolivas.org, linux list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 07 April 2006 16:25, Nick Piggin wrote:
> Con Kolivas wrote:
> > It is possible with a low enough lowmem_reserve ratio to make
> > zone_watermark_ok always fail if the lower_zone is small enough.
>
> I don't see how this would happen?

3GB lowmem and a reserve ratio of 180 is enough to do it.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

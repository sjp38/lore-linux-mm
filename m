Received: by wf-out-1314.google.com with SMTP id 28so76319wfc.11
        for <linux-mm@kvack.org>; Thu, 16 Oct 2008 09:25:49 -0700 (PDT)
Message-ID: <2f11576a0810160925u3fa9c206k58226eebfe096113@mail.gmail.com>
Date: Fri, 17 Oct 2008 01:25:49 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] Subject: [PATCH] Report the pagesize backing a VMA in /proc/pid/smaps
In-Reply-To: <1224172715-17667-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1224172715-17667-1-git-send-email-mel@csn.ul.ie>
	 <1224172715-17667-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi

> It is useful to verify a hugepage-aware application is using the expected
> pagesizes for its memory regions. This patch creates an entry called
> KernelPageSize in /proc/pid/smaps that is the size of page used by the
> kernel to back a VMA. The entry is not called PageSize as it is possible
> the MMU uses a different size. This extension should not break any sensible
> parser that skips lines containing unrecognised information.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

ack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id D29156B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 22:37:25 -0400 (EDT)
Message-ID: <4FEA71E5.5090808@kernel.org>
Date: Wed, 27 Jun 2012 11:37:25 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] zram/zcache: swtich Kconfig dependency from X86 to
 ZSMALLOC
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-2-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1340640878-27536-2-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 06/26/2012 01:14 AM, Seth Jennings wrote:

> This patch switches zcache and zram dependency to ZSMALLOC
> rather than X86.  There is no net change since ZSMALLOC
> depends on X86, however, this prevent further changes to
> these files as zsmalloc dependencies change.
> 
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

Reviewed-by: Minchan Kim <minchan@kernel.org>

It could be merged regardless of other patches in this series.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

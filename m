Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id ED8BB6B0062
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 04:05:51 -0400 (EDT)
Message-ID: <1340870676.1976.1.camel@localhost>
Subject: Re: [announce] pagemap-demo-ng tools
From: Anton Arapov <anton@redhat.com>
Date: Thu, 28 Jun 2012 10:04:36 +0200
In-Reply-To: <201206261811.48256.b.zolnierkie@samsung.com>
References: <201206261811.48256.b.zolnierkie@samsung.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Kyungmin Park <kyungmin.park@samsung.com>

  / apologizes for the top post /

Please,
  also take a look at: https://fedorahosted.org/libpagemap/ project.

thanks,
Anton.

On Tue, 2012-06-26 at 18:11 +0200, Bartlomiej Zolnierkiewicz wrote:
> Hi,
> 
> I got agreement from Matt to takeover maintenance of demo scripts
> for the /proc/$pid/pagemap and /proc/kpage[count,flags] interfaces
> (originally hosted at http://selenic.com/repo/pagemap/).
> 
> The updated tools are available at:
> 
> 	https://github.com/bzolnier/pagemap-demo-ng
> 
> Changes include:
> 
> * support for recent kernels
> * support for platforms using ARCH_PFN_OFFSET (i.e ARM Exynos)
>   (needs [1] & [2])
> * possibility to work on data captured on another machine
> * optional support for monitoring free/used pages (needs [3])
> * optional support for monitoring pageblock type changes (needs [4])
> 
> [1] http://article.gmane.org/gmane.linux.kernel.mm/79435/
> [2] http://article.gmane.org/gmane.linux.kernel.mm/79432/ 
> [3] http://article.gmane.org/gmane.linux.kernel.mm/79431/
> [4] http://article.gmane.org/gmane.linux.kernel.mm/79433/
> 
> Best regards,
> --
> Bartlomiej Zolnierkiewicz
> Samsung Poland R&D Center
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

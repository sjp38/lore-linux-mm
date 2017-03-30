Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 330356B0038
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 17:06:21 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a72so57823083pge.10
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 14:06:21 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id o1si2941314pld.248.2017.03.30.14.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 14:06:20 -0700 (PDT)
Date: Thu, 30 Mar 2017 16:06:17 -0500
From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH 9/9] kernel-api.rst: fix a series of errors when parsing
 C files
Message-ID: <20170330210617.GA28207@bhelgaas-glaptop.roam.corp.google.com>
References: <cover.1490904090.git.mchehab@s-opensource.com>
 <5c39bc852b201759de4cf901f7e9ad04715285d9.1490904090.git.mchehab@s-opensource.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5c39bc852b201759de4cf901f7e9ad04715285d9.1490904090.git.mchehab@s-opensource.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mauro Carvalho Chehab <mchehab@s-opensource.com>
Cc: Linux Media Mailing List <linux-media@vger.kernel.org>, Linux Doc Mailing List <linux-doc@vger.kernel.org>, Mauro Carvalho Chehab <mchehab@infradead.org>, Jens Axboe <axboe@kernel.dk>, Bjorn Helgaas <bhelgaas@google.com>, Russell King <linux@armlinux.org.uk>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-clk@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org

On Thu, Mar 30, 2017 at 05:11:36PM -0300, Mauro Carvalho Chehab wrote:
> ./lib/string.c:134: WARNING: Inline emphasis start-string without end-string.
> ./mm/filemap.c:522: WARNING: Inline interpreted text or phrase reference start-string without end-string.
> ./mm/filemap.c:1283: ERROR: Unexpected indentation.
> ./mm/filemap.c:3003: WARNING: Inline interpreted text or phrase reference start-string without end-string.
> ./mm/vmalloc.c:1544: WARNING: Inline emphasis start-string without end-string.
> ./mm/page_alloc.c:4245: ERROR: Unexpected indentation.
> ./ipc/util.c:676: ERROR: Unexpected indentation.
> ./drivers/pci/irq.c:35: WARNING: Block quote ends without a blank line; unexpected unindent.
> ./security/security.c:109: ERROR: Unexpected indentation.
> ./security/security.c:110: WARNING: Definition list ends without a blank line; unexpected unindent.
> ./block/genhd.c:275: WARNING: Inline strong start-string without end-string.
> ./block/genhd.c:283: WARNING: Inline strong start-string without end-string.
> ./include/linux/clk.h:134: WARNING: Inline emphasis start-string without end-string.
> ./include/linux/clk.h:134: WARNING: Inline emphasis start-string without end-string.
> ./ipc/util.c:477: ERROR: Unknown target name: "s".
> 
> Signed-off-by: Mauro Carvalho Chehab <mchehab@s-opensource.com>

Acked-by: Bjorn Helgaas <bhelgaas@google.com>	# for drivers/pci/irq.c

> diff --git a/drivers/pci/irq.c b/drivers/pci/irq.c
> index 6684f153ab57..f9f2a0324ecc 100644
> --- a/drivers/pci/irq.c
> +++ b/drivers/pci/irq.c
> @@ -31,7 +31,7 @@ static void pci_note_irq_problem(struct pci_dev *pdev, const char *reason)
>   * driver).
>   *
>   * Returns:
> - *  a suggestion for fixing it (although the driver is not required to
> + * a suggestion for fixing it (although the driver is not required to
>   * act on this).
>   */
>  enum pci_lost_interrupt_reason pci_lost_interrupt(struct pci_dev *pdev)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

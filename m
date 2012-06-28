Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 20D3E6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 02:26:03 -0400 (EDT)
Received: by qabg27 with SMTP id g27so3159677qab.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 23:26:02 -0700 (PDT)
Date: Thu, 28 Jun 2012 02:25:59 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: RE: [PATCH] [RESEND] arm: limit memblock base address for
 early_pte_alloc
In-Reply-To: <00e801cd54f0$eb8a3540$c29e9fc0$@lge.com>
Message-ID: <alpine.LFD.2.02.1206280223250.31003@xanadu.home>
References: <1338880312-17561-1-git-send-email-minchan@kernel.org> <025701cd457e$d5065410$7f12fc30$@lge.com> <20120627160220.GA2310@linaro.org> <00e801cd54f0$eb8a3540$c29e9fc0$@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kim, Jong-Sung" <neidhard.kim@lge.com>
Cc: 'Dave Martin' <dave.martin@linaro.org>, 'Minchan Kim' <minchan@kernel.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Catalin Marinas' <catalin.marinas@arm.com>, 'Chanho Min' <chanho.min@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On Thu, 28 Jun 2012, Kim, Jong-Sung wrote:

> > From: Dave Martin [mailto:dave.martin@linaro.org]
> > Sent: Thursday, June 28, 2012 1:02 AM
> > 
> > For me, it appears that this block just contains the initial region passed
> > in ATAG_MEM or on the command line, with some reservations for
> > swapper_pg_dir, the kernel text/data, device tree and initramfs.
> > 
> > So far as I can tell, the only memory guaranteed to be mapped here is the
> > kernel image: there may be no guarantee that there is any unused space in
> > this region which could be used to allocate extra page tables.
> > The rest appears during the execution of map_lowmem().
> > 
> > Cheers
> > ---Dave
> 
> Thank you for your comment, Dave! It was not that sophisticated choice, but
> I thought that normal embedded system trying to reduce the BOM would have a
> big-enough first memblock memory region. However you're right. There can be
> exceptional systems. Then, how do you think about following manner:
[...]

This still has some possibilities for failure.

Please have a look at the two patches I've posted to fix this in a 
better way.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id BFC996B0035
	for <linux-mm@kvack.org>; Fri, 19 Sep 2014 06:00:23 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so3589539pab.29
        for <linux-mm@kvack.org>; Fri, 19 Sep 2014 03:00:23 -0700 (PDT)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id oc7si2134773pdb.116.2014.09.19.03.00.21
        for <linux-mm@kvack.org>;
        Fri, 19 Sep 2014 03:00:22 -0700 (PDT)
Date: Fri, 19 Sep 2014 11:00:02 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH resend] arm:extend the reserved memory for initrd to be
 page aligned
Message-ID: <20140919095959.GA2295@e104818-lin.cambridge.arm.com>
References: <35FD53F367049845BC99AC72306C23D103D6DB49161F@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103D6DB49161F@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: Will Deacon <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Uwe =?iso-8859-1?Q?Kleine-K=F6nig'?= <u.kleine-koenig@pengutronix.de>, DL-WW-ContributionOfficers-Linux <DL-WW-ContributionOfficers-Linux@sonymobile.com>

On Fri, Sep 19, 2014 at 08:09:47AM +0100, Wang, Yalin wrote:
> this patch extend the start and end address of initrd to be page aligned,
> so that we can free all memory including the un-page aligned head or tail
> page of initrd, if the start or end address of initrd are not page
> aligned, the page can't be freed by free_initrd_mem() function.
> 
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

(as I said, if Russell doesn't have any objections please send the patch
to his patch system)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

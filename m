Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 095816B009F
	for <linux-mm@kvack.org>; Thu, 18 Sep 2014 12:04:53 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id et14so1797520pad.14
        for <linux-mm@kvack.org>; Thu, 18 Sep 2014 09:04:53 -0700 (PDT)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id rn6si40398555pab.165.2014.09.18.09.04.51
        for <linux-mm@kvack.org>;
        Thu, 18 Sep 2014 09:04:51 -0700 (PDT)
Date: Thu, 18 Sep 2014 17:04:34 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH Resend] arm:extend the reserved mrmory for initrd to be
 page aligned
Message-ID: <20140918160434.GC25330@e104818-lin.cambridge.arm.com>
References: <35FD53F367049845BC99AC72306C23D103D6DB491616@CNBJMBX05.corpusers.net>
 <20140918055553.GO3755@pengutronix.de>
 <35FD53F367049845BC99AC72306C23D103D6DB491619@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103D6DB491619@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Uwe =?iso-8859-1?Q?Kleine-K=F6nig'?= <u.kleine-koenig@pengutronix.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Thu, Sep 18, 2014 at 07:53:57AM +0100, Wang, Yalin wrote:
> This patch extends the start and end address of initrd to be page aligned,
> so that we can free all memory including the un-page aligned head or tail
> page of initrd, if the start or end address of initrd are not page
> aligned, the page can't be freed by free_initrd_mem() function.
> 
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>

You still have a typo in the subject.

For the arm64 part:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

so you can merge it via Russell's patch system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

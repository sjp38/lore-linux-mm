Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id CBDFA6B0068
	for <linux-mm@kvack.org>; Thu, 18 Sep 2014 01:56:07 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id z11so452649lbi.35
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 22:56:06 -0700 (PDT)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:6f8:1178:4:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id jd4si14301970lac.131.2014.09.17.22.56.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 22:56:05 -0700 (PDT)
Date: Thu, 18 Sep 2014 07:55:53 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] arm:extend the reserved mrmory for initrd to be page
 aligned
Message-ID: <20140918055553.GO3755@pengutronix.de>
References: <35FD53F367049845BC99AC72306C23D103D6DB491616@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <35FD53F367049845BC99AC72306C23D103D6DB491616@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>

Hello,

just some commit log nit picking:

$Subject ~= s/mrmory/memory/

And also "ARM: " is the more typical prefix. Don't know if there is a
best practice for patches touching both arm and arm64. (But assuming
this will go through Russell's patch tracker this doesn't matter much.)

On Thu, Sep 18, 2014 at 09:58:10AM +0800, Wang, Yalin wrote:
> this patch extend the start and end address of initrd to be page aligned,
This patch extends ...

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-Konig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

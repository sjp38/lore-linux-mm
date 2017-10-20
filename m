Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A79286B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 02:03:51 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b79so8758657pfk.9
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 23:03:51 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id k10si220542pgq.447.2017.10.19.23.03.50
        for <linux-mm@kvack.org>;
        Thu, 19 Oct 2017 23:03:50 -0700 (PDT)
Date: Fri, 20 Oct 2017 15:03:47 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v2 2/3] lockdep: Remove BROKEN flag of
 LOCKDEP_CROSSRELEASE
Message-ID: <20171020060347.GE3310@X58A-UD3R>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
 <1508392531-11284-3-git-send-email-byungchul.park@lge.com>
 <1508425527.2429.11.camel@wdc.com>
 <alpine.DEB.2.20.1710191718260.1971@nanos>
 <1508428021.2429.22.camel@wdc.com>
 <alpine.DEB.2.20.1710192021480.2054@nanos>
 <alpine.DEB.2.20.1710192107000.2054@nanos>
 <1508444515.2429.55.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508444515.2429.55.camel@wdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kernel-team@lge.com" <kernel-team@lge.com>

On Thu, Oct 19, 2017 at 08:21:56PM +0000, Bart Van Assche wrote:
> * How much review has the Documentation/locking/crossrelease.txt received
>   before it went upstream? At least to me that document seems much harder
>   to read than other kernel documentation due to weird use of the English
>   grammar.

Sorry for the bad English. Please help it enhanced.

For others, Thomas and Matthew already did exactly what to say, well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 13D9D900021
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 01:21:41 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id r10so2498658igi.0
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 22:21:40 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0137.hostedemail.com. [216.40.44.137])
        by mx.google.com with ESMTP id e8si4913472ioj.65.2014.10.28.22.21.40
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 22:21:40 -0700 (PDT)
Message-ID: <1414560096.10912.18.camel@perches.com>
Subject: Re: [RFC V4 1/3] add CONFIG_HAVE_ARCH_BITREVERSE to support rbit
 instruction
From: Joe Perches <joe@perches.com>
Date: Tue, 28 Oct 2014 22:21:36 -0700
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E010D1825F@CNBJMBX05.corpusers.net>
References: 
	<35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
	 <1414392371.8884.2.camel@perches.com>
	 <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
	 <35FD53F367049845BC99AC72306C23D103E010D1825F@CNBJMBX05.corpusers.net>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Rob Herring' <robherring2@gmail.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, 2014-10-29 at 13:14 +0800, Wang, Yalin wrote:
> this change add CONFIG_HAVE_ARCH_BITREVERSE config option,
> so that we can use arm/arm64 rbit instruction to do bitrev operation
> by hardware.

> We also change byte_rev_table[] to be static,
> to make sure no drivers can access it directly.

You break the build with this patch.

You can't do this until the users of the table
are converted.

So far, they are not.

I submitted patches for these uses, but those patches
are not yet applied.

Please make sure the dependencies for your patches
are explicitly stated.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

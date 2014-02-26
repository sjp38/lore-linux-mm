Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 26C186B00A4
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:02:07 -0500 (EST)
Received: by mail-qa0-f50.google.com with SMTP id cm18so2340363qab.23
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:02:06 -0800 (PST)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id y4si575037qad.9.2014.02.26.07.02.05
        for <linux-mm@kvack.org>;
        Wed, 26 Feb 2014 07:02:06 -0800 (PST)
Date: Wed, 26 Feb 2014 09:02:03 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [LSF/MM ATTEND] slab cache extension -- slab cache in fixed
 size
In-Reply-To: <530D9216.8050808@oracle.com>
Message-ID: <alpine.DEB.2.10.1402260901180.22259@nuc>
References: <52D662A4.1080502@oracle.com> <alpine.DEB.2.10.1401310941430.6849@nuc> <530C0F08.1040000@oracle.com> <alpine.DEB.2.10.1402251225280.30822@nuc> <530D9216.8050808@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Wed, 26 Feb 2014, Jeff Liu wrote:

> Yes, so that we can enabled those debug functions for both slab and slub, thanks for
> your direction. :)

I have tried to work on that on and off for a bit but I never had the time
to get this through. Keep me posted on any progres.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 20D8F6B0038
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:06:13 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so109434pad.27
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:06:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gr4si2898930pac.196.2014.08.27.16.06.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 16:06:12 -0700 (PDT)
Date: Wed, 27 Aug 2014 16:06:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] x86: Speed up ioremap operations
Message-Id: <20140827160610.4ef142d28fd7f276efd38a51@linux-foundation.org>
In-Reply-To: <20140827225927.364537333@asylum.americas.sgi.com>
References: <20140827225927.364537333@asylum.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On Wed, 27 Aug 2014 17:59:27 -0500 Mike Travis <travis@sgi.com> wrote:

> 
> We have a large university system in the UK that is experiencing
> very long delays modprobing the driver for a specific I/O device.
> The delay is from 8-10 minutes per device and there are 31 devices
> in the system.  This 4 to 5 hour delay in starting up those I/O
> devices is very much a burden on the customer.

That's nuts.

> There are two causes for requiring a restart/reload of the drivers.
> First is periodic preventive maintenance (PM) and the second is if
> any of the devices experience a fatal error.  Both of these trigger
> this excessively long delay in bringing the system back up to full
> capability.
> 
> The problem was tracked down to a very slow IOREMAP operation and
> the excessively long ioresource lookup to insure that the user is
> not attempting to ioremap RAM.  These patches provide a speed up
> to that function.

With what result?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

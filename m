Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id F19F76B0037
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 16:16:06 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so7193236pab.17
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 13:16:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m2si2107213pdb.58.2014.08.29.13.16.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Aug 2014 13:16:05 -0700 (PDT)
Date: Fri, 29 Aug 2014 13:16:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] x86: Speed up ioremap operations
Message-Id: <20140829131602.72c422ebd2fd3fba426379e8@linux-foundation.org>
In-Reply-To: <20140829195328.511550688@asylum.americas.sgi.com>
References: <20140829195328.511550688@asylum.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On Fri, 29 Aug 2014 14:53:28 -0500 Mike Travis <travis@sgi.com> wrote:

> 
> We have a large university system in the UK that is experiencing
> very long delays modprobing the driver for a specific I/O device.
> The delay is from 8-10 minutes per device and there are 31 devices
> in the system.  This 4 to 5 hour delay in starting up those I/O
> devices is very much a burden on the customer.
> 
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
> 

Really would prefer to have some quantitative testing results in here,
as that is the entire point of the patchset.  And it leaves the reader
wondering "how much of this severe problem remains?".

Also, the -stable backport is a big ask, isn't it?  It's arguably
notabug and the affected number of machines is small.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

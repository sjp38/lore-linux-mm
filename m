Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id BFCEE6B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 02:48:30 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id x48so288391wes.40
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 23:48:30 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id az10si6182795wib.11.2014.08.27.23.48.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 23:48:29 -0700 (PDT)
Received: by mail-wi0-f171.google.com with SMTP id hi2so6921736wib.16
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 23:48:29 -0700 (PDT)
Date: Thu, 28 Aug 2014 08:48:25 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/2] x86: Speed up ioremap operations
Message-ID: <20140828064825.GA6059@gmail.com>
References: <20140827225927.364537333@asylum.americas.sgi.com>
 <20140827160610.4ef142d28fd7f276efd38a51@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140827160610.4ef142d28fd7f276efd38a51@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Travis <travis@sgi.com>, mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 27 Aug 2014 17:59:27 -0500 Mike Travis <travis@sgi.com> wrote:
> 
> > 
> > We have a large university system in the UK that is experiencing
> > very long delays modprobing the driver for a specific I/O device.
> > The delay is from 8-10 minutes per device and there are 31 devices
> > in the system.  This 4 to 5 hour delay in starting up those I/O
> > devices is very much a burden on the customer.
> 
> That's nuts.

Agreed, and I'd suggest marking this for -stable, once it's all 
settled and tested.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

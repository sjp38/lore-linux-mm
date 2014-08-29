Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1B26F6B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:16:51 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id rl12so3307678iec.15
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:16:50 -0700 (PDT)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id x6si13258135igr.45.2014.08.29.12.16.50
        for <linux-mm@kvack.org>;
        Fri, 29 Aug 2014 12:16:50 -0700 (PDT)
Message-Id: <20140829191647.364032240@asylum.americas.sgi.com>
Date: Fri, 29 Aug 2014 14:16:47 -0500
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 0/2] x86: Speed up ioremap operations
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com
Cc: akpm@linux-foundation.org, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org


We have a large university system in the UK that is experiencing
very long delays modprobing the driver for a specific I/O device.
The delay is from 8-10 minutes per device and there are 31 devices
in the system.  This 4 to 5 hour delay in starting up those I/O
devices is very much a burden on the customer.

There are two causes for requiring a restart/reload of the drivers.
First is periodic preventive maintenance (PM) and the second is if
any of the devices experience a fatal error.  Both of these trigger
this excessively long delay in bringing the system back up to full
capability.

The problem was tracked down to a very slow IOREMAP operation and
the excessively long ioresource lookup to insure that the user is
not attempting to ioremap RAM.  These patches provide a speed up
to that function.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

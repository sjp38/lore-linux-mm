Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id DF0D16B0037
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 18:59:30 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id lx4so184421iec.32
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 15:59:30 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id x6si7442067igr.45.2014.08.27.15.59.29
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 15:59:29 -0700 (PDT)
Message-Id: <20140827225927.364537333@asylum.americas.sgi.com>
Date: Wed, 27 Aug 2014 17:59:27 -0500
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

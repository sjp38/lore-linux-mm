Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 679906B04A4
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 19:33:08 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id 73so55078oti.14
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 16:33:08 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c24sor765276otd.48.2018.01.03.16.33.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 16:33:07 -0800 (PST)
Date: Wed, 3 Jan 2018 16:33:03 -0800
From: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
Message-ID: <20180104003303.GA1654@trogon.sfo.coreos.systems>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
 <20180103084600.GA31648@trogon.sfo.coreos.systems>
 <20180103092016.GA23772@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180103092016.GA23772@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jan 03, 2018 at 10:20:16AM +0100, Greg Kroah-Hartman wrote:
> Ick, not good, any chance you can test 4.15-rc6 to verify that the issue
> is also there (or not)?

I haven't been able to reproduce this on 4.15-rc6.

--Benjamin Gilbert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3FC6B04B4
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 20:37:47 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e26so152616pfi.15
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 17:37:47 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r2sor662515plo.52.2018.01.03.17.37.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 17:37:46 -0800 (PST)
Date: Wed, 3 Jan 2018 17:37:42 -0800
From: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
Message-ID: <20180104013742.GA5911@trogon.sfo.coreos.systems>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
 <20180103084600.GA31648@trogon.sfo.coreos.systems>
 <20180103092016.GA23772@kroah.com>
 <20180104003303.GA1654@trogon.sfo.coreos.systems>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180104003303.GA1654@trogon.sfo.coreos.systems>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jan 03, 2018 at 04:33:03PM -0800, Benjamin Gilbert wrote:
> I haven't been able to reproduce this on 4.15-rc6.

This is bad data.  I was caught by the fact that 4.14.11 has
PAGE_TABLE_ISOLATION default y but 4.15-rc6 doesn't.  Retesting.

--Benjamin Gilbert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

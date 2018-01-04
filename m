Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 41F686B02D1
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 23:36:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id m9so400662pff.0
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 20:36:35 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f19sor811233plj.59.2018.01.03.20.36.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 20:36:34 -0800 (PST)
Date: Wed, 3 Jan 2018 20:36:31 -0800
From: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
Message-ID: <20180104043631.GA14421@trogon.sfo.coreos.systems>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
 <20180103084600.GA31648@trogon.sfo.coreos.systems>
 <20180103092016.GA23772@kroah.com>
 <20180104003303.GA1654@trogon.sfo.coreos.systems>
 <20180104013742.GA5911@trogon.sfo.coreos.systems>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180104013742.GA5911@trogon.sfo.coreos.systems>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jan 03, 2018 at 05:37:42PM -0800, Benjamin Gilbert wrote:
> I was caught by the fact that 4.14.11 has PAGE_TABLE_ISOLATION default y
> but 4.15-rc6 doesn't.  Retesting.

It turns out that 4.15-rc6 has the same problem as 4.14.11.

--Benjamin Gilbert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

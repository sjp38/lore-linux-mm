Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 35D326B04CE
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 02:22:20 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v184so348990wmf.1
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 23:22:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d48sor1343616wrd.33.2018.01.03.23.22.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 23:22:19 -0800 (PST)
Date: Thu, 4 Jan 2018 08:22:16 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
Message-ID: <20180104072216.qvcomyzmx3x6leph@gmail.com>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
 <20180103084600.GA31648@trogon.sfo.coreos.systems>
 <20180103092016.GA23772@kroah.com>
 <20180104003303.GA1654@trogon.sfo.coreos.systems>
 <alpine.DEB.2.20.1801040136390.1957@nanos>
 <20180104071421.aaqikae3gh23ew4l@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180104071421.aaqikae3gh23ew4l@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Benjamin Gilbert <benjamin.gilbert@coreos.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>


* Ingo Molnar <mingo@kernel.org> wrote:

> These will cherry-pick cleanly, so it would be nice to test them on top of of the 
> -stable kernel that fails:
> 
>   for N in 450cbdd0125c 4d2dc2cc766c 1e0f25dbf246 be62a3204406 0c3292ca8025 9d0b62328d34; do git cherry-pick $N; done
> 
> if this brute-force approach resolves the problem then we have a shorter list of 
> fixes to look at.

As per Greg's followup this should not matter - but nevertheless for completeness 
these commits also need f54bb2ec02c83 as a dependency, so the full list is:

   for N in 450cbdd0125c 4d2dc2cc766c 1e0f25dbf246 be62a3204406 0c3292ca8025 9d0b62328d34 f54bb2ec02c83; do git cherry-pick $N; done

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

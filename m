Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1BD16B04CC
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 02:20:34 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id s105so407921wrc.23
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 23:20:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l8sor1295324wrc.42.2018.01.03.23.20.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 23:20:33 -0800 (PST)
Date: Thu, 4 Jan 2018 08:20:31 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
Message-ID: <20180104072031.copd24chvxr27aze@gmail.com>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
 <20180103084600.GA31648@trogon.sfo.coreos.systems>
 <20180103092016.GA23772@kroah.com>
 <20180104003303.GA1654@trogon.sfo.coreos.systems>
 <alpine.DEB.2.20.1801040136390.1957@nanos>
 <20180104071421.aaqikae3gh23ew4l@gmail.com>
 <20180104071813.GB27317@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180104071813.GB27317@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Benjamin Gilbert <benjamin.gilbert@coreos.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>


* Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:

> On Thu, Jan 04, 2018 at 08:14:21AM +0100, Ingo Molnar wrote:
> >  - (or it's something I missed to consider)
> 
> It was a operator error, the issue is also on 4.15-rc6, see another
> email in this thread :)

ah, ok :-)

Nevertheless it made sense to go through all the backport candidate commits again, 
nothing stuck out as a must-have for -stable! ;-)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

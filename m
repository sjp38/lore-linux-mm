Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0DA2E8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 07:40:50 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id ay11so15314989plb.20
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 04:40:50 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s8si7539978pgl.503.2019.01.22.04.40.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 04:40:47 -0800 (PST)
Date: Tue, 22 Jan 2019 13:40:44 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v25 0/6] Add io{read|write}64 to io-64-atomic headers
Message-ID: <20190122124044.GA11753@kroah.com>
References: <20190116182523.19446-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190116182523.19446-1-logang@deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-ntb@googlegroups.com, linux-crypto@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andy.shevchenko@gmail.com>, Horia =?utf-8?Q?Geant=C4=83?= <horia.geanta@nxp.com>

On Wed, Jan 16, 2019 at 11:25:17AM -0700, Logan Gunthorpe wrote:
> This is resend number 6 since the last change to this series.
> 
> This cleanup was requested by Greg KH back in June of 2017. I've resent the series
> a couple times a cycle since then, updating and fixing as feedback was slowly
> recieved some patches were alread accepted by specific arches. In June 2018,
> Andrew picked the remainder of this up and it was in linux-next for a
> couple weeks. There were a couple problems that were identified and addressed
> back then and I'd really like to get the ball rolling again. A year
> and a half of sending this without much feedback is far too long.
> 
> @Andrew, can you please pick this set up again so it can get into
> linux-next? Or let me know if there's something else I should be doing.

version 25?  That's crazy, this has gone on too long.  I've taken this
into my char/misc driver tree now, so sorry for the long suffering you
have gone through for this.

Thanks for being persistent,

greg k-h

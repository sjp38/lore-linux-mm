Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id E71196B0070
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 22:06:44 -0500 (EST)
Received: from mail-ea0-f169.google.com ([209.85.215.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TdXz1-0006ig-Sd
	for linux-mm@kvack.org; Wed, 28 Nov 2012 03:06:43 +0000
Received: by mail-ea0-f169.google.com with SMTP id a12so5341239eaa.14
        for <linux-mm@kvack.org>; Tue, 27 Nov 2012 19:06:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1354069667.BsTEhItmLz@vostro.rjw.lan>
References: <1353761958-12810-1-git-send-email-ming.lei@canonical.com>
	<1353761958-12810-6-git-send-email-ming.lei@canonical.com>
	<1354069667.BsTEhItmLz@vostro.rjw.lan>
Date: Wed, 28 Nov 2012 11:06:43 +0800
Message-ID: <CACVXFVOAt8hrNenEthRZEqv2d6g+gzSPUCBV=RU_u=bxs+9VTw@mail.gmail.com>
Subject: Re: [PATCH v6 5/6] PM / Runtime: force memory allocation with no I/O
 during Runtime PM callbcack
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 28, 2012 at 5:24 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>
> Please don't duplicate code this way.
>
> You can move that whole thing to rpm_callback().  Yes, you'll probably need to
> check dev->power.memalloc_noio twice in there, but that's OK.

Good idea, I will update it in v7.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 8E3626B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 19:18:12 -0400 (EDT)
Received: from mail-ea0-f169.google.com ([209.85.215.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TThY3-0006w6-GE
	for linux-mm@kvack.org; Wed, 31 Oct 2012 23:18:11 +0000
Received: by mail-ea0-f169.google.com with SMTP id k11so961894eaa.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 16:18:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.44L0.1210311139300.1954-100000@iolanthe.rowland.org>
References: <Pine.LNX.4.44L0.1210311117310.1954-100000@iolanthe.rowland.org>
	<Pine.LNX.4.44L0.1210311139300.1954-100000@iolanthe.rowland.org>
Date: Thu, 1 Nov 2012 07:18:11 +0800
Message-ID: <CACVXFVM=JTxBc7dUNgAYg3oEveASZMJEvSuTjR+_u0E1ZCUHkA@mail.gmail.com>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Oliver Neukum <oneukum@suse.de>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 31, 2012 at 11:41 PM, Alan Stern <stern@rowland.harvard.edu> wrote:
>
> Sorry, I misread your message.  You are setting the device's flag, not
> the thread's flag.

Never mind.

>
> This still doesn't help in this case where CONFIG_PM_RUNTIME is
> disabled.  I think it will be simpler to set the noio flag during every
> device reset.

Yes, it's better to set the flag during every device reset now.

Also pppoe or network interface over serial port is a bit difficult to
deal with, as Oliver pointed out.


Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 891366B004D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 04:47:20 -0500 (EST)
Received: from mail-ea0-f169.google.com ([209.85.215.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TdeEh-0003HZ-FV
	for linux-mm@kvack.org; Wed, 28 Nov 2012 09:47:19 +0000
Received: by mail-ea0-f169.google.com with SMTP id a12so5458721eaa.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 01:47:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1408044.6czCGhbHJH@vostro.rjw.lan>
References: <1353761958-12810-1-git-send-email-ming.lei@canonical.com>
	<5434404.G1ERYjuorE@vostro.rjw.lan>
	<CACVXFVODD9fRqQc3kR58OJm3ERgBWojnx=790xGwu=MPGaSmMA@mail.gmail.com>
	<1408044.6czCGhbHJH@vostro.rjw.lan>
Date: Wed, 28 Nov 2012 17:47:18 +0800
Message-ID: <CACVXFVOk45wr8jv3w=KO7uTThGSTSkq0FRsPD6p_AyQZLWGQJg@mail.gmail.com>
Subject: Re: [PATCH v6 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 28, 2012 at 5:29 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>
> But it doesn't have to walk the children.  Moreover, with counters it only

Yeah, I got it, it is the advantage of counter, but with extra 'int'
field introduced
in 'struct device'.

> needs to walk the whole path if all devices in it need to be updated.  For
> example, if you call pm_runtime_set_memalloc_noio(dev, true) for a device
> whose parent's counter is greater than zero already, you don't need to
> walk the path above the parent.

We still can do it with the flag only, pm_runtime_set_memalloc_noio(dev, true)
can return immediately if one parent or the 'dev' flag is true.

But considered that the pm_runtime_set_memalloc_noio(dev, false) is only
called in a very infrequent path(network/block device->remove()), looks the
introduced cost isn't worthy of the obtained advantage.

So could you accept not introducing counter? and I will update with the
above improvement you suggested.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

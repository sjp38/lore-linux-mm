Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 649D96B0078
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 23:34:38 -0500 (EST)
Received: from mail-ee0-f41.google.com ([74.125.83.41])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TdZM5-0000rF-CC
	for linux-mm@kvack.org; Wed, 28 Nov 2012 04:34:37 +0000
Received: by mail-ee0-f41.google.com with SMTP id d41so8999808eek.14
        for <linux-mm@kvack.org>; Tue, 27 Nov 2012 20:34:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5434404.G1ERYjuorE@vostro.rjw.lan>
References: <1353761958-12810-1-git-send-email-ming.lei@canonical.com>
	<1353761958-12810-3-git-send-email-ming.lei@canonical.com>
	<5434404.G1ERYjuorE@vostro.rjw.lan>
Date: Wed, 28 Nov 2012 12:34:36 +0800
Message-ID: <CACVXFVODD9fRqQc3kR58OJm3ERgBWojnx=790xGwu=MPGaSmMA@mail.gmail.com>
Subject: Re: [PATCH v6 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 28, 2012 at 5:19 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>
> Please use counters instead of walking the whole path every time.  Ie. in
> addition to the flag add a counter to store the number of the device's
> children having that flag set.

Even though counter is added, walking the whole path can't be avoided too,
and may be a explicit walking or recursion, because pm_runtime_set_memalloc_noio
is required to set or clear the flag(or increase/decrease the counter) of
devices in the whole path.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

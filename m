Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id A3F1C6B0069
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 04:44:40 -0400 (EDT)
Received: from mail-wg0-f45.google.com ([74.125.82.45])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TQa6J-0005Sz-Oz
	for linux-mm@kvack.org; Tue, 23 Oct 2012 08:44:39 +0000
Received: by mail-wg0-f45.google.com with SMTP id dq12so2515199wgb.26
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 01:44:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.44L0.1210221035450.1724-100000@iolanthe.rowland.org>
References: <1350894794-1494-7-git-send-email-ming.lei@canonical.com>
	<Pine.LNX.4.44L0.1210221035450.1724-100000@iolanthe.rowland.org>
Date: Tue, 23 Oct 2012 16:44:39 +0800
Message-ID: <CACVXFVOy+dmjdhBr9Vtww12PZg_fo2y78TcNzuP_Yq9_p=74Hw@mail.gmail.com>
Subject: Re: [RFC PATCH v2 6/6] USB: forbid memory allocation with I/O during
 bus reset
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: linux-kernel@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 22, 2012 at 10:37 PM, Alan Stern <stern@rowland.harvard.edu> wrote:
> On Mon, 22 Oct 2012, Ming Lei wrote:

>>
>> +     /*
>> +      * Don't allocate memory with GFP_KERNEL in current
>> +      * context to avoid possible deadlock if usb mass
>> +      * storage interface or usbnet interface(iSCSI case)
>> +      * is included in current configuration. The easiest
>> +      * approach is to do it for all devices.
>> +      */
>> +     memalloc_noio_save(noio_flag);
>
> Why not check dev->power.memalloc_noio_resume here too?

Yes, we can use the flag here too even though it is introduced
for rutime_resume case.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 46FCC6B002B
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 07:30:16 -0400 (EDT)
Received: from mail-ea0-f169.google.com ([209.85.215.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TTA1P-0006ty-58
	for linux-mm@kvack.org; Tue, 30 Oct 2012 11:30:15 +0000
Received: by mail-ea0-f169.google.com with SMTP id k11so91982eaa.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2012 04:30:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2149424.HsnQpSLjK5@linux-lqwf.site>
References: <1351513440-9286-3-git-send-email-ming.lei@canonical.com>
	<Pine.LNX.4.44L0.1210291125590.22882-100000@netrider.rowland.org>
	<CACVXFVOPDu6wVgPmvtTkokn7VV41x3XVvL4g_E0pz0mikUbvUg@mail.gmail.com>
	<2149424.HsnQpSLjK5@linux-lqwf.site>
Date: Tue, 30 Oct 2012 19:30:14 +0800
Message-ID: <CACVXFVMTg6k09AWTDZKQCJTBTUGwQ0OoHhdCLFdcbbCv5kzTjw@mail.gmail.com>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver Neukum <oneukum@suse.de>
Cc: Alan Stern <stern@rowland.harvard.edu>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

Hi,

On Tue, Oct 30, 2012 at 6:57 PM, Oliver Neukum <oneukum@suse.de> wrote:
> how is this to work with power management domains?

Could you explain it in a bit detail? Why is PM domain involved?

Suppose PM domain is involved, its domain runtime_resume callback
is still run in the context with PF_MEMALLOC_NOIO flag set if the
affected 'device' is passed to the callback.

> And I may be dense, but disks are added in slave_configure().
> This seems to be a race to me.

Sorry, could you describe what is the race?

Suppose drivers set correct parent device to the disk device(gendisk),
then add the disk into device model via register_disk(), the solution
should be fine.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

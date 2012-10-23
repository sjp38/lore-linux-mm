Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id AE54E6B0062
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 04:42:03 -0400 (EDT)
Received: from mail-we0-f169.google.com ([74.125.82.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TQa3m-0005QU-LQ
	for linux-mm@kvack.org; Tue, 23 Oct 2012 08:42:02 +0000
Received: by mail-we0-f169.google.com with SMTP id u3so2316997wey.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 01:42:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.44L0.1210221516280.1724-100000@iolanthe.rowland.org>
References: <1350894794-1494-5-git-send-email-ming.lei@canonical.com>
	<Pine.LNX.4.44L0.1210221516280.1724-100000@iolanthe.rowland.org>
Date: Tue, 23 Oct 2012 16:42:02 +0800
Message-ID: <CACVXFVMzwUAmPn2rsALGTRcBN2w2MSVsbAMmJK4Pb_Cs5ksDcA@mail.gmail.com>
Subject: Re: [RFC PATCH v2 4/6] net/core: apply pm_runtime_set_memalloc_noio
 on network devices
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: linux-kernel@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, David Decotigny <david.decotigny@google.com>, Tom Herbert <therbert@google.com>, Ingo Molnar <mingo@elte.hu>

On Tue, Oct 23, 2012 at 3:18 AM, Alan Stern <stern@rowland.harvard.edu> wrote:
> On Mon, 22 Oct 2012, Ming Lei wrote:

> Is this really needed?  Even with iSCSI, doesn't register_disk() have
> to be called for the underlying block device?  And given your 3/6
> patch, wouldn't that mark the network device?

The problem is that network device is not one ancestor of the
iSCSI disk device, which transfers data over tcp stack.


Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

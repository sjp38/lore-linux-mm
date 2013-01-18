Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 8F6B56B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 05:23:02 -0500 (EST)
Received: from mail-vc0-f175.google.com ([209.85.220.175])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1Tw96D-0005H2-B3
	for linux-mm@kvack.org; Fri, 18 Jan 2013 10:23:01 +0000
Received: by mail-vc0-f175.google.com with SMTP id fw7so778064vcb.34
        for <linux-mm@kvack.org>; Fri, 18 Jan 2013 02:23:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130117135726.5b31fd0f.akpm@linux-foundation.org>
References: <1357352744-8138-1-git-send-email-ming.lei@canonical.com>
	<20130116153744.70210fa3.akpm@linux-foundation.org>
	<CACVXFVOipr0VMyPQaZTLckxTaPan7ZneERUqZ1S_mYo11A5AeA@mail.gmail.com>
	<20130117135726.5b31fd0f.akpm@linux-foundation.org>
Date: Fri, 18 Jan 2013 18:22:59 +0800
Message-ID: <CACVXFVPEcZCCxA1+EeW-qdouiaBMPPjx7fn+jbROzSwBRN58SA@mail.gmail.com>
Subject: Re: [PATCH v7 0/6] solve deadlock caused by memory allocation with I/O
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>

On Fri, Jan 18, 2013 at 5:57 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> Fair enough, thanks.
>
> I grabbed the patches for 3.9-rc1.  It is good that the page
> allocator's newly-added test of current->flags is not on the fastpath.
>

Andrew, great thanks, :-)

Also thank Alan, Oliver, Minchan, Rafael, Greg and other guys who
reviewed and gave suggestions on this patch set.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

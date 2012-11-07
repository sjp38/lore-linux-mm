Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 588976B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 22:37:20 -0500 (EST)
Received: from mail-ee0-f41.google.com ([74.125.83.41])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TVwS7-0000Kf-Ec
	for linux-mm@kvack.org; Wed, 07 Nov 2012 03:37:19 +0000
Received: by mail-ee0-f41.google.com with SMTP id c4so796921eek.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2012 19:37:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121106152303.b1e135ee.akpm@linux-foundation.org>
References: <1351931714-11689-1-git-send-email-ming.lei@canonical.com>
	<20121106152303.b1e135ee.akpm@linux-foundation.org>
Date: Wed, 7 Nov 2012 11:37:19 +0800
Message-ID: <CACVXFVM8Z55mHV791TF19kH5J6u_yEXK_=nmu6qk2hiXzn+M9w@mail.gmail.com>
Subject: Re: [PATCH v4 0/6] solve deadlock caused by memory allocation with I/O
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 7, 2012 at 7:23 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> It generally looks OK to me.  I have a few comments and I expect to grab
> v5.

Andrew, thanks for your review, and I will prepare -v5 later.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

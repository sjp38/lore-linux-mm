Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 5E1E26B0044
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 14:13:34 -0500 (EST)
Message-ID: <50BF9CD8.4020209@fusionio.com>
Date: Wed, 5 Dec 2012 20:13:28 +0100
From: Jens Axboe <jaxboe@fusionio.com>
MIME-Version: 1.0
Subject: Re: [patch,v3] bdi: add a user-tunable cpu_list for the bdi flusher
 threads
References: <x49ip8g9w66.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49ip8g9w66.fsf@segfault.boston.devel.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Zach Brown <zab@redhat.com>, Dave Chinner <david@fromorbit.com>, "jeder@redhat.com" <jeder@redhat.com>

On 2012-12-05 19:43, Jeff Moyer wrote:
> In realtime environments, it may be desirable to keep the per-bdi
> flusher threads from running on certain cpus.  This patch adds a
> cpu_list file to /sys/class/bdi/* to enable this.  The default is to tie
> the flusher threads to the same numa node as the backing device (though
> I could be convinced to make it a mask of all cpus to avoid a change in
> behaviour).

This looks fine to me now. I'll queue it up for 3.8.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

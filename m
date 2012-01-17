Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 46C316B00B8
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 08:32:36 -0500 (EST)
Received: by vbbfa15 with SMTP id fa15so2089353vbb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 05:32:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5b429d6c4d0a3ad06ec01193eab7edc98a03e0de.1326803859.git.leonid.moiseichuk@nokia.com>
References: <cover.1326803859.git.leonid.moiseichuk@nokia.com>
	<5b429d6c4d0a3ad06ec01193eab7edc98a03e0de.1326803859.git.leonid.moiseichuk@nokia.com>
Date: Tue, 17 Jan 2012 15:32:35 +0200
Message-ID: <CAOJsxLFCbF8azY48_SHhYQ0oRDrf2-rEvGMKHBne2Znpj0XL4g@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] Memory notification pseudo-device module
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Tue, Jan 17, 2012 at 3:22 PM, Leonid Moiseichuk
<leonid.moiseichuk@nokia.com> wrote:
> The memory notification (memnotify) device tracks level of memory utilization,
> active page set and notifies subscribed processes when consumption crossed
> specified threshold(s) up or down. It could be used on embedded devices to
> implementation of performance-cheap memory reacting by using
> e.g. libmemnotify or similar user-space component.
>
> The minimal (250 ms) and maximal (15s) periods of reaction and granularity
> (~1.4% of memory size) could be tuned using module options.
>
> Signed-off-by: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>

Is the point of making this a misc device to keep the ABI compatible
with N9? Is the ABI documented?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D439F6B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 06:27:55 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id b22so630127898pfd.0
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 03:27:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 3si88542012plz.149.2017.01.09.03.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 03:27:55 -0800 (PST)
Date: Mon, 9 Jan 2017 12:28:15 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] stable-fixup: hotplug: fix unused function warning
Message-ID: <20170109112815.GA8187@kroah.com>
References: <20170109104811.1453295-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170109104811.1453295-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Yu Zhao <yuzhao@google.com>, linux-kernel@vger.kernel.org

On Mon, Jan 09, 2017 at 11:47:50AM +0100, Arnd Bergmann wrote:
> The backport of upstream commit 777c6e0daebb ("hotplug: Make
> register and unregister notifier API symmetric") to linux-4.4.y
> introduced a harmless warning in 'allnoconfig' builds as spotted by
> kernelci.org:
> 
> kernel/cpu.c:226:13: warning: 'cpu_notify_nofail' defined but not used [-Wunused-function]
> 
> So far, this is the only stable tree that is affected, as linux-4.6 and
> higher contain commit 984581728eb4 ("cpu/hotplug: Split out cpu down functions")
> that makes the function used in all configurations, while older longterm
> releases so far don't seem to have a backport of 777c6e0daebb.
> 
> The fix for the warning is trivial: move the unused function back
> into the #ifdef section where it was before.
> 
> Link: https://kernelci.org/build/id/586fcacb59b514049ef6c3aa/logs/
> Fixes: 1c0f4e0ebb79 ("hotplug: Make register and unregister notifier API symmetric") in v4.4.y
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  kernel/cpu.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)

Thanks for this, now applied.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

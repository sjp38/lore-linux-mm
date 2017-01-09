Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 11FC56B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 06:47:33 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f188so1928781118pgc.1
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 03:47:33 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t22si55075494plj.276.2017.01.09.03.47.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 03:47:32 -0800 (PST)
Date: Mon, 9 Jan 2017 12:47:52 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] stable-fixup: hotplug: fix unused function warning
Message-ID: <20170109114752.GA12325@kroah.com>
References: <20170109104811.1453295-1-arnd@arndb.de>
 <20170109112918.GH7495@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170109112918.GH7495@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>, stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Yu Zhao <yuzhao@google.com>, linux-kernel@vger.kernel.org

On Mon, Jan 09, 2017 at 12:29:18PM +0100, Michal Hocko wrote:
> On Mon 09-01-17 11:47:50, Arnd Bergmann wrote:
> > The backport of upstream commit 777c6e0daebb ("hotplug: Make
> > register and unregister notifier API symmetric") to linux-4.4.y
> > introduced a harmless warning in 'allnoconfig' builds as spotted by
> > kernelci.org:
> > 
> > kernel/cpu.c:226:13: warning: 'cpu_notify_nofail' defined but not used [-Wunused-function]
> 
> Is this warning really worth bothering? Does any stable rely on warning
> free builds?

Yes, I watch it, it's a good indicator that I got a backport wrong.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4806B00E1
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 09:59:46 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id j15so8116299qaq.30
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 06:59:45 -0700 (PDT)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id c8si290307qab.121.2014.04.14.06.59.44
        for <linux-mm@kvack.org>;
        Mon, 14 Apr 2014 06:59:44 -0700 (PDT)
Date: Mon, 14 Apr 2014 08:59:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -next] slub: Replace __this_cpu_inc usage w/ SLUB_STATS
In-Reply-To: <20140414153424.0eca4c7d@datenkhaos.de>
Message-ID: <alpine.DEB.2.10.1404140858100.17469@nuc>
References: <20140306194821.3715d0b6212cc10415374a68@canb.auug.org.au> <20140306155316.GG18529@joshc.qualcomm.com> <20140306182941.GH18529@joshc.qualcomm.com> <20140414153424.0eca4c7d@datenkhaos.de>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Hirte <johannes.hirte@datenkhaos.de>
Cc: Josh Cartwright <joshc@codeaurora.org>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Mon, 14 Apr 2014, Johannes Hirte wrote:

> kernel/watchdog.c:
>
> void touch_softlockup_watchdog(void)
> {
>         __this_cpu_write(watchdog_touch_ts, 0);
> }
> EXPORT_SYMBOL(touch_softlockup_watchdog);
>
> Don't know if the change to this_cpu_write() is the right way here too.

Well yes lets change that to this_cpu_write(). I doubt there are
significant performance issues here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

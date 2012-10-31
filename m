Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 1FFE96B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 13:46:04 -0400 (EDT)
Date: Wed, 31 Oct 2012 18:46:01 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
Message-ID: <20121031174601.GI24389@liondog.tnic>
References: <20121012125708.GJ10110@dhcp22.suse.cz>
 <20121024210600.GA17037@liondog.tnic>
 <20121024141303.0797d6a1.akpm@linux-foundation.org>
 <1787395.7AzIesGUbB@vostro.rjw.lan>
 <20121024181752.de011615.akpm@linux-foundation.org>
 <alpine.LRH.2.00.1210290958450.10392@twin.jikos.cz>
 <20121029095819.GA4326@liondog.tnic>
 <20121031173154.GA20660@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121031173154.GA20660@elf.ucw.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Jiri Kosina <jkosina@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Dave Hansen <dave@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 31, 2012 at 06:31:54PM +0100, Pavel Machek wrote:
> Hmm? When I resume from hibernate, I want to use my machine.

Well, in my case with a workstation with 8 Gb, the only time the swapin
is noticeable is when I try to use firefox with a couple of dozens tabs
open. Once that thing is swapped in, system perf is back to normal.

I'll bet that even this slowdown would disappear if I use an SSD.

But I can imagine some workloads where swapping everything back in could
be discomforting.

> Kernel will not normally swap anything in automatically. Some people
> do swapoff -a; swapon -a to work around that. (And yes, maybe some
> automatic-swap-in-when-there's-plenty-of-RAM would be useful.).

That's a good idea, actually.

So, in any case, the current situation is fine as it is, I'd say: people
can decide whether they want to drop caches before suspending or not.
Problem solved.

Thanks.

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id F00616B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 06:11:22 -0400 (EDT)
Date: Mon, 29 Oct 2012 11:11:20 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
Message-ID: <20121029101120.GC4326@liondog.tnic>
References: <20121012125708.GJ10110@dhcp22.suse.cz>
 <20121024210600.GA17037@liondog.tnic>
 <20121024141303.0797d6a1.akpm@linux-foundation.org>
 <1787395.7AzIesGUbB@vostro.rjw.lan>
 <20121024181752.de011615.akpm@linux-foundation.org>
 <alpine.LRH.2.00.1210290958450.10392@twin.jikos.cz>
 <20121029095819.GA4326@liondog.tnic>
 <alpine.LNX.2.00.1210291100470.19184@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1210291100470.19184@pobox.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Dave Hansen <dave@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 29, 2012 at 11:01:59AM +0100, Jiri Kosina wrote:
> Well if the point of dropping caches is lowering the resume time, then
> the point is rendered moot as soon as you switch to your browser and
> have to wait noticeable amount of time until it starts reacting.

Not the resume time - the suspend time. If, say, one has 8Gb of memory
and Linux nicely spreads all over it in caches, you don't want to wait
too long for the suspend image creation.

And nowadays, since you can have 8Gb in a laptop, you really want to
keep that image minimal so that suspend-to-disk is quick.

The penalty of faulting everything back in is a cost we'd be willing to
pay, I guess.

Thanks.

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

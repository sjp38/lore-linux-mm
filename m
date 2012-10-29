Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 9E1C96B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 05:58:22 -0400 (EDT)
Date: Mon, 29 Oct 2012 10:58:19 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
Message-ID: <20121029095819.GA4326@liondog.tnic>
References: <20121012125708.GJ10110@dhcp22.suse.cz>
 <20121024210600.GA17037@liondog.tnic>
 <20121024141303.0797d6a1.akpm@linux-foundation.org>
 <1787395.7AzIesGUbB@vostro.rjw.lan>
 <20121024181752.de011615.akpm@linux-foundation.org>
 <alpine.LRH.2.00.1210290958450.10392@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.00.1210290958450.10392@twin.jikos.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Dave Hansen <dave@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 29, 2012 at 09:59:59AM +0100, Jiri Kosina wrote:
> You might or might not want to do that. Dropping caches around suspend
> makes the hibernation process itself faster, but the realtime response
> of the applications afterwards is worse, as everything touched by user
> has to be paged in again.

Right, do you know of a real use-case where people hibernate, then
resume and still care about applications response time right afterwards?

Besides, once everything is swapped back in, perf. is back to normal,
i.e. like before suspending.

Thanks.

-- 
Regards/Gruss,
    Boris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

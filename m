Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 36BA96B0062
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 14:12:14 -0500 (EST)
Received: by vcge1 with SMTP id e1so4372987vcg.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 11:12:13 -0800 (PST)
Date: Mon, 19 Dec 2011 11:12:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Android low memory killer vs. memory pressure notifications
In-Reply-To: <20111219121255.GA2086@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1112191110060.19949@chino.kir.corp.google.com>
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru> <20111219121255.GA2086@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, =?UTF-8?Q?Arve_Hj=C3=B8nnev=C3=A5g?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, 19 Dec 2011, Michal Hocko wrote:

> page_cgroup is 16B per page and with the current Johannes' memcg
> naturalization work (in the mmotm tree) we are down to 8B per page (we
> got rid of lru). Kamezawa has some patches to get rid of the flags so we
> will be down to 4B per page on 32b. Is this still too much?
> I would be really careful about a yet another lowmem notification
> mechanism.
> 

There was always general interest in a low memory notification mechanism 
even prior to memcg, see http://lwn.net/Articles/268732/ from Marcelo and 
KOSAKI-san.  The desire is not only to avoid the metadata overhead of 
memcg, but also to avoid cgroups entirely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id DC1736B0033
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 14:48:05 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id o13so5877788qaj.17
        for <linux-mm@kvack.org>; Mon, 08 Jul 2013 11:48:04 -0700 (PDT)
Message-ID: <51DB0962.50209@gmail.com>
Date: Mon, 08 Jul 2013 14:48:02 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: Honor min_free_kbytes set by user
References: <1372954036-16988-1-git-send-email-mhocko@suse.cz> <1372954239.1886.40.camel@joe-AO722> <20130704161641.GD7833@dhcp22.suse.cz> <20130704162005.GE7833@dhcp22.suse.cz>
In-Reply-To: <20130704162005.GE7833@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Checkpatch fixes
> ---
>  From 5f089c0b2a57ff6c08710ac9698d65aede06079f Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 4 Jul 2013 17:15:54 +0200
> Subject: [PATCH] mm: Honor min_free_kbytes set by user
>
> min_free_kbytes is updated during memory hotplug (by init_per_zone_wmark_min)
> currently which is right thing to do in most cases but this could be
> unexpected if admin increased the value to prevent from allocation
> failures and the new min_free_kbytes would be decreased as a result of
> memory hotadd.
>
> This patch saves the user defined value and allows updating
> min_free_kbytes only if it is higher than the saved one.
>
> A warning is printed when the new value is ignored.
>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Thank you. I have similar patch and I have been bothered long time to
refine and post it.
Yes, current logic is not memory hotplug aware and could be dangerous.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

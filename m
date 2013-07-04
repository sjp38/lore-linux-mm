Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id BB7066B0033
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 12:10:40 -0400 (EDT)
Message-ID: <1372954239.1886.40.camel@joe-AO722>
Subject: Re: [RFC] mm: Honor min_free_kbytes set by user
From: Joe Perches <joe@perches.com>
Date: Thu, 04 Jul 2013 09:10:39 -0700
In-Reply-To: <1372954036-16988-1-git-send-email-mhocko@suse.cz>
References: <1372954036-16988-1-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2013-07-04 at 18:07 +0200, Michal Hocko wrote:
> A warning is printed when the new value is ignored.

[]

> +		printk(KERN_WARNING "min_free_kbytes is not updated to %d"
> +				"because user defined value %d is preferred\n",
> +				new_min_free_kbytes, user_min_free_kbytes);

Please use pr_warn and coalesce the format.
You'd've noticed a missing space between %d and because.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

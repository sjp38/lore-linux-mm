Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 6AA3C6B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 00:40:15 -0400 (EDT)
Message-ID: <50861FA9.2030506@xenotime.net>
Date: Mon, 22 Oct 2012 21:40:09 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
Subject: Re: mmotm 2012-10-22-17-08 uploaded (memory_hotplug.c)
References: <20121023000924.C56EF5C0050@hpza9.eem.corp.google.com>
In-Reply-To: <20121023000924.C56EF5C0050@hpza9.eem.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org

On 10/22/2012 05:09 PM, akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2012-10-22-17-08 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 



on x86_64, when CONFIG_MEMORY_HOTREMOVE is not enabled:

mm/built-in.o: In function `online_pages':
(.ref.text+0x10e7): undefined reference to `zone_pcp_reset'


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 735D96B0006
	for <linux-mm@kvack.org>; Sat, 19 Jan 2013 14:17:42 -0500 (EST)
Message-ID: <50FAF197.5010700@infradead.org>
Date: Sat, 19 Jan 2013 11:18:47 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: mmotm 2013-01-18-15-48 uploaded (memory_hotplug.c)
References: <20130118234944.5C99C31C240@corp2gmr1-1.hot.corp.google.com>
In-Reply-To: <20130118234944.5C99C31C240@corp2gmr1-1.hot.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org

On 01/18/13 15:49, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2013-01-18-15-48 has been uploaded to
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


mm/memory_hotplug.c:1092:29: warning: the address of 'contig_page_data' will always evaluate as 'true' [-Waddress]



-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

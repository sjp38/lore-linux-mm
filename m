Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 7371F8D0002
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 11:20:29 -0400 (EDT)
Received: by mail-oa0-f47.google.com with SMTP id g12so5422465oah.20
        for <linux-mm@kvack.org>; Thu, 08 Aug 2013 08:20:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130807153030.GA25515@redhat.com>
References: <20130807055157.GA32278@redhat.com>
	<CAJd=RBCJv7=Qj6dPW2Ha=nq6JctnK3r7wYCAZTm=REVOZUNowg@mail.gmail.com>
	<20130807153030.GA25515@redhat.com>
Date: Thu, 8 Aug 2013 23:20:28 +0800
Message-ID: <CAJd=RBCyZU8PR7mbFUdKsWq3OH+5HccEWKMEH5u7GNHNy3esWg@mail.gmail.com>
Subject: Re: unused swap offset / bad page map.
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

On Wed, Aug 7, 2013 at 11:30 PM, Dave Jones <davej@redhat.com> wrote:
> printk didn't trigger.
>
Is a corrupted page table entry encountered, according to the
comment of swap_duplicate()?


--- a/mm/swapfile.c	Wed Aug  7 17:27:22 2013
+++ b/mm/swapfile.c	Thu Aug  8 23:12:30 2013
@@ -770,6 +770,7 @@ int free_swap_and_cache(swp_entry_t entr
 		unlock_page(page);
 		page_cache_release(page);
 	}
+	return 1;
 	return p != NULL;
 }

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

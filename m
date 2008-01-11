Date: Fri, 11 Jan 2008 15:24:34 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
In-Reply-To: <20080108210002.638347207@redhat.com>
References: <20080108205939.323955454@redhat.com> <20080108210002.638347207@redhat.com>
Message-Id: <20080111143627.FD64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi Rik

> +static inline int is_file_lru(enum lru_list l)
> +{
> +	BUILD_BUG_ON(LRU_INACTIVE_FILE != 2 || LRU_ACTIVE_FILE != 3);
> +	return (l/2 == 1);
> +}

below patch is a bit cleanup proposal.
i think LRU_FILE is more clarify than "/2".

What do you think it?



Index: linux-2.6.24-rc6-mm1-rvr/include/linux/mmzone.h
===================================================================
--- linux-2.6.24-rc6-mm1-rvr.orig/include/linux/mmzone.h        2008-01-11 11:10:30.000000000 +0900
+++ linux-2.6.24-rc6-mm1-rvr/include/linux/mmzone.h     2008-01-11 14:40:31.000000000 +0900
@@ -147,7 +147,7 @@
 static inline int is_file_lru(enum lru_list l)
 {
        BUILD_BUG_ON(LRU_INACTIVE_FILE != 2 || LRU_ACTIVE_FILE != 3);
-       return (l/2 == 1);
+       return !!(l & LRU_FILE);
 }

 struct per_cpu_pages {



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

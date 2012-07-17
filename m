Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id C7C1E6B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 04:54:53 -0400 (EDT)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@shangw.pok.ibm.com>;
	Tue, 17 Jul 2012 04:54:52 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id EBAF46E8054
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 04:54:48 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6H8smWV363348
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 04:54:48 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6H8smBh000954
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 05:54:48 -0300
Date: Tue, 17 Jul 2012 16:59:33 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/vmscan: remove checking on PG_lru
Message-ID: <20120717085933.GA21120@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1342500254-28384-1-git-send-email-shangw@linux.vnet.ibm.com>
 <20120717084513.GA24218@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120717084513.GA24218@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

>Hello Gavin,
>
>On Tue, Jul 17, 2012 at 12:44:14PM +0800, Gavin Shan wrote:
>> Function __isolate_lru_page() is called by isolate_lru_pages() or
>> isolate_migratepages_range(). For both cases, the PG_lru flag for
>
>In isolate_lru_pages, the check is with VM_BUG_ON so if we disable
>CONFIG_DEBUG_VM, we still need it.
>

Thanks, Minchan. Sorry for the noise then :-)

Gavin

>-- 
>Kind regards,
>Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

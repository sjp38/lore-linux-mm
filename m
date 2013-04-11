Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id CEEF46B0037
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:04:30 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r11so1019271pdi.7
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:04:30 -0700 (PDT)
Date: Thu, 11 Apr 2013 13:04:28 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 05/10] staging: ramster: Move debugfs code out of
 ramster.c file
Message-ID: <20130411200428.GA31680@kroah.com>
References: <1365553560-32258-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1365553560-32258-6-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1365553560-32258-6-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>

On Wed, Apr 10, 2013 at 08:25:55AM +0800, Wanpeng Li wrote:
> Note that at this point there is no CONFIG_RAMSTER_DEBUG
> option in the Kconfig. So in effect all of the counters
> are nop until that option gets re-introduced in:
> zcache/ramster/debug: Add RAMSTE_DEBUG Kconfig entry

This patch breaks the build badly:

drivers/staging/zcache/ramster/ramster.c: In function a??ramster_localifya??:
drivers/staging/zcache/ramster/ramster.c:159:4: error: a??ramster_remote_eph_pages_unsucc_geta?? undeclared (first use in this function)
drivers/staging/zcache/ramster/ramster.c:159:4: note: each undeclared identifier is reported only once for each function it appears in
drivers/staging/zcache/ramster/ramster.c:161:4: error: a??ramster_remote_pers_pages_unsucc_geta?? undeclared (first use in this function)
drivers/staging/zcache/ramster/ramster.c:212:3: error: a??ramster_remote_eph_pages_succ_geta?? undeclared (first use in this function)
drivers/staging/zcache/ramster/ramster.c:214:3: error: a??ramster_remote_pers_pages_succ_geta?? undeclared (first use in this function)
drivers/staging/zcache/ramster/ramster.c: In function a??ramster_pampd_repatriate_preloada??:
drivers/staging/zcache/ramster/ramster.c:299:3: error: a??ramster_pers_pages_remote_nomema?? undeclared (first use in this function)
drivers/staging/zcache/ramster/ramster.c: In function a??ramster_remote_flush_pagea??:
drivers/staging/zcache/ramster/ramster.c:437:3: error: a??ramster_remote_pages_flusheda?? undeclared (first use in this function)
drivers/staging/zcache/ramster/ramster.c:439:3: error: a??ramster_remote_page_flushes_faileda?? undeclared (first use in this function)
drivers/staging/zcache/ramster/ramster.c: In function a??ramster_remote_flush_objecta??:
drivers/staging/zcache/ramster/ramster.c:454:3: error: a??ramster_remote_objects_flusheda?? undeclared (first use in this function)
drivers/staging/zcache/ramster/ramster.c:456:3: error: a??ramster_remote_object_flushes_faileda?? undeclared (first use in this function)
drivers/staging/zcache/ramster/ramster.c: In function a??ramster_remotify_pageframea??:
drivers/staging/zcache/ramster/ramster.c:507:5: error: a??ramster_eph_pages_remote_faileda?? undeclared (first use in this function)
drivers/staging/zcache/ramster/ramster.c:509:5: error: a??ramster_pers_pages_remote_faileda?? undeclared (first use in this function)
drivers/staging/zcache/ramster/ramster.c:516:4: error: a??ramster_eph_pages_remoteda?? undeclared (first use in this function)
drivers/staging/zcache/ramster/ramster.c:518:4: error: a??ramster_pers_pages_remoteda?? undeclared (first use in this function)
make[3]: *** [drivers/staging/zcache/ramster/ramster.o] Error 1

Please always test your patches.

I've applied patch 1, 3, and 4 in this series.  Please fix this up if you want
me to apply anything else.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

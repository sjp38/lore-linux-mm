Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 4DC3A6B0002
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 18:16:07 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id 5so1624952pdd.31
        for <linux-mm@kvack.org>; Fri, 12 Apr 2013 15:16:06 -0700 (PDT)
Date: Fri, 12 Apr 2013 15:16:03 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH PART2 v2 2/7] staging: ramster: Move debugfs code out of
 ramster.c file
Message-ID: <20130412221603.GA11282@kroah.com>
References: <1365730287-16876-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1365730287-16876-3-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365730287-16876-3-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>

On Fri, Apr 12, 2013 at 09:31:22AM +0800, Wanpeng Li wrote:
> Note that at this point there is no CONFIG_RAMSTER_DEBUG
> option in the Kconfig. So in effect all of the counters
> are nop until that option gets re-introduced in:
> zcache/ramster/debug: Add RAMSTE_DEBUG Kconfig entry

RAMSTE_DEBUG?  :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

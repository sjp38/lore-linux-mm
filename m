Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id A0C176B002B
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 13:33:02 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 12 Dec 2012 13:33:01 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 011E5C90042
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 13:32:58 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBCIWv02322976
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 13:32:57 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBCIWv7c029645
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 13:32:57 -0500
Message-ID: <50C8CDD7.8040302@linux.vnet.ibm.com>
Date: Wed, 12 Dec 2012 12:32:55 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] zswap: compressed swap caching
References: <1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com> <20121211220148.GA12821@kroah.com> <50C8B0EA.6040205@linux.vnet.ibm.com> <59a1d7ee-e5dc-4923-8544-605c35c632af@default>
In-Reply-To: <59a1d7ee-e5dc-4923-8544-605c35c632af@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 12/12/2012 11:27 AM, Dan Magenheimer wrote:
> Related, are you now comfortable with abandoning "zcache1" and
> moving "zcache2" (now in drivers/staging/ramster in 3.7) to become
> the one-and-only in-tree drivers/staging/zcache (with ramster
> as a subdirectory and build option)?  It would be nice to get
> rid of that artificial and confusing distinction as soon as possible,
> especially if, due to zswap, you have no plans to continue to
> maintain/enhance/promote zcache1 anymore.

Yes, that's fine by me.  I guess that didn't get said explicitly in
the last discussion so sorry for any confusion.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

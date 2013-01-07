Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 8A5EE6B0062
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 15:42:06 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 7 Jan 2013 15:42:05 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 92231C90026
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 15:42:01 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r07KfxV1231362
	for <linux-mm@kvack.org>; Mon, 7 Jan 2013 15:42:00 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r07KfZNt026150
	for <linux-mm@kvack.org>; Mon, 7 Jan 2013 13:41:36 -0700
Message-ID: <50EB32FB.30802@linux.vnet.ibm.com>
Date: Mon, 07 Jan 2013 14:41:31 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 5/9] debugfs: add get/set for atomic types
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com> <1357590280-31535-6-git-send-email-sjenning@linux.vnet.ibm.com> <20130107203219.GA19596@kroah.com>
In-Reply-To: <20130107203219.GA19596@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Robert Jennings <rcj@linux.vnet.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Nitin Gupta <ngupta@vflare.org>, Jenifer Hopper <jhopper@us.ibm.com>

On 01/07/2013 02:32 PM, Greg Kroah-Hartman wrote:
> On Mon, Jan 07, 2013 at 02:24:36PM -0600, Seth Jennings wrote:
>> debugfs currently lack the ability to create attributes
>> that set/get atomic_t values.
> 
> I hate to ask, but why would you ever want to do such a thing?

There are a few atomic_t statistics in zswap that are valuable to have
in the debugfs attributes.  Rather than have non-atomic mirrors of all
of them, as is done in zcache right now (see
drivers/staging/ramster/zcache-main.c:131), I thought this to be a
cleaner solution.

Granted, I personally have no use for the setting part; only the
getting part.  I only included the setting operations to keep the
balance and conform with the rest of the debugfs implementation.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

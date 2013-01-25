Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 6F82C6B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 11:45:23 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 25 Jan 2013 11:45:22 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id DF627C90042
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 11:45:19 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0PGjJOh22282352
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 11:45:19 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0PGjHMW018724
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 11:45:19 -0500
Message-ID: <5102B690.4090503@linux.vnet.ibm.com>
Date: Fri, 25 Jan 2013 10:45:04 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 5/9] debugfs: add get/set for atomic types
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com> <1357590280-31535-6-git-send-email-sjenning@linux.vnet.ibm.com> <20130107203219.GA19596@kroah.com> <50EB32FB.30802@linux.vnet.ibm.com>
In-Reply-To: <50EB32FB.30802@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Robert Jennings <rcj@linux.vnet.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Nitin Gupta <ngupta@vflare.org>, Jenifer Hopper <jhopper@us.ibm.com>

On 01/07/2013 02:41 PM, Seth Jennings wrote:
> On 01/07/2013 02:32 PM, Greg Kroah-Hartman wrote:
>> On Mon, Jan 07, 2013 at 02:24:36PM -0600, Seth Jennings wrote:
>>> debugfs currently lack the ability to create attributes
>>> that set/get atomic_t values.
>>
>> I hate to ask, but why would you ever want to do such a thing?
> 
> There are a few atomic_t statistics in zswap that are valuable to have
> in the debugfs attributes.  Rather than have non-atomic mirrors of all
> of them, as is done in zcache right now (see
> drivers/staging/ramster/zcache-main.c:131), I thought this to be a
> cleaner solution.
> 
> Granted, I personally have no use for the setting part; only the
> getting part.  I only included the setting operations to keep the
> balance and conform with the rest of the debugfs implementation.

Greg, I never did get your ack or rejection here.  Are you ok with
this patch?

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

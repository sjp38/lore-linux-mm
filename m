Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 3B8AA6B00A4
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 13:56:13 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 29 Jan 2013 13:56:12 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 992D2C90044
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 13:56:06 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0TIu3eI295802
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 13:56:04 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0TItwj6001056
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 11:55:58 -0700
Message-ID: <51081B3B.5080001@linux.vnet.ibm.com>
Date: Tue, 29 Jan 2013 12:55:55 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 5/6] zswap: add to mm/
References: <1359409767-30092-1-git-send-email-sjenning@linux.vnet.ibm.com> <1359409767-30092-6-git-send-email-sjenning@linux.vnet.ibm.com> <20130129062756.GH4752@blaptop>
In-Reply-To: <20130129062756.GH4752@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/29/2013 12:27 AM, Minchan Kim wrote:
<snip>
> On Mon, Jan 28, 2013 at 03:49:26PM -0600, Seth Jennings wrote:
<snip>
>> +/*********************************
>> +* tunables
>> +**********************************/
>> +/* Enable/disable zswap (enabled by default, fixed at boot for now) */
>> +static bool zswap_enabled;
>> +module_param_named(enabled, zswap_enabled, bool, 0);
> 
> It seems default is disable at the moment?

I completely missed what you were saying before.  The comment is
incorrect :)  I'll fix it.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

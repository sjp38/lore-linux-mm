Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 491936B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 16:24:11 -0400 (EDT)
Message-ID: <5193EEE7.80603@sr71.net>
Date: Wed, 15 May 2013 13:24:07 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv11 3/4] zswap: add to mm/
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com> <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com> <15c5b1da-132a-4c9e-9f24-bc272d3865d5@default> <20130514163541.GC4024@medulla> <f0272a06-141a-4d33-9976-ee99467f3aa2@default> <20130514225501.GA11956@cerebellum> <4d74f5db-11c1-4f58-97f4-8d96bbe601ac@default> <20130515185506.GA23342@phenom.dumpdata.com> <20130515200942.GA17724@cerebellum>
In-Reply-To: <20130515200942.GA17724@cerebellum>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 05/15/2013 01:09 PM, Seth Jennings wrote:
> On Wed, May 15, 2013 at 02:55:06PM -0400, Konrad Rzeszutek Wilk wrote:
>>> Sorry, but I don't think that's appropriate for a patch in the MM subsystem.
>>
>> Perhaps a compromise can be reached where this code is merged as a driver
>> not a core mm component. There is a high bar to be in the MM - it has to
>> work with many many different configurations. 
>>
>> And drivers don't have such a high bar. They just need to work on a specific
>> issue and that is it. If zswap ended up in say, drivers/mm that would make
>> it more palpable I think.

The issue is not whether it is a loadable module or a driver.  Nobody
here is stupid enough to say, "hey, now it's a driver/module, all of the
complex VM interactions are finally fixed!"

If folks don't want this in their system, there's a way to turn it off,
today, with the sysfs tunables.  We don't need _another_ way to turn it
off at runtime (unloading the module/driver).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

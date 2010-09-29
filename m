Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED0C6B004A
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 09:16:49 -0400 (EDT)
Date: Wed, 29 Sep 2010 05:37:52 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/8] v2 De-Couple sysfs memory directories from memory
	sections
Message-ID: <20100929123752.GA18865@kroah.com>
References: <4CA0EBEB.1030204@austin.ibm.com> <4CA1E338.6070201@redhat.com> <20100928151218.GJ14068@sgi.com> <20100929025035.GA13096@kroah.com> <4CA2F9A2.3090202@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CA2F9A2.3090202@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Robin Holt <holt@sgi.com>, Nathan Fontenot <nfont@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 29, 2010 at 10:32:34AM +0200, Avi Kivity wrote:
>  On 09/29/2010 04:50 AM, Greg KH wrote:
>> >
>> >  Because the old ABI creates 129,000+ entries inside
>> >  /sys/devices/system/memory with their associated links from
>> >  /sys/devices/system/node/node*/ back to those directory entries.
>> >
>> >  Thankfully things like rpm, hald, and other miscellaneous commands scan
>> >  that information.
>>
>> Really?  Why?  Why would rpm care about this?  hald is dead now so we
>> don't need to worry about that anymore,
>
> That's not what compatiblity means.  We can't just support 
> latest-and-greatest userspace on latest-and-greatest kernels.

Oh, I know that, that's not what I was getting at at all here, sorry if
it came across that way.

I wanted to know so we could go fix programs that are mucking around in
these files, as odds are, the shouldn't be doing that in the first
place.

Like rpm, why would it matter what the memory in the system looks like?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

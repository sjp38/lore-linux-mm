Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 946B56B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 04:32:52 -0400 (EDT)
Message-ID: <4CA2F9A2.3090202@redhat.com>
Date: Wed, 29 Sep 2010 10:32:34 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] v2 De-Couple sysfs memory directories from memory
 sections
References: <4CA0EBEB.1030204@austin.ibm.com> <4CA1E338.6070201@redhat.com> <20100928151218.GJ14068@sgi.com> <20100929025035.GA13096@kroah.com>
In-Reply-To: <20100929025035.GA13096@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Robin Holt <holt@sgi.com>, Nathan Fontenot <nfont@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

  On 09/29/2010 04:50 AM, Greg KH wrote:
> >
> >  Because the old ABI creates 129,000+ entries inside
> >  /sys/devices/system/memory with their associated links from
> >  /sys/devices/system/node/node*/ back to those directory entries.
> >
> >  Thankfully things like rpm, hald, and other miscellaneous commands scan
> >  that information.
>
> Really?  Why?  Why would rpm care about this?  hald is dead now so we
> don't need to worry about that anymore,

That's not what compatiblity means.  We can't just support 
latest-and-greatest userspace on latest-and-greatest kernels.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

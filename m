Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D310E6B0047
	for <linux-mm@kvack.org>; Sun,  3 Oct 2010 03:53:06 -0400 (EDT)
Message-ID: <4CA83651.1010502@redhat.com>
Date: Sun, 03 Oct 2010 09:52:49 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] v2 De-Couple sysfs memory directories from memory
 sections
References: <4CA0EBEB.1030204@austin.ibm.com> <4CA1E338.6070201@redhat.com> <20100928151218.GJ14068@sgi.com> <20100929025035.GA13096@kroah.com> <4CA2F9A2.3090202@redhat.com> <20100929123752.GA18865@kroah.com>
In-Reply-To: <20100929123752.GA18865@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Robin Holt <holt@sgi.com>, Nathan Fontenot <nfont@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

  On 09/29/2010 02:37 PM, Greg KH wrote:
> >>  >   Thankfully things like rpm, hald, and other miscellaneous commands scan
> >>  >   that information.
> >>
> >>  Really?  Why?  Why would rpm care about this?  hald is dead now so we
> >>  don't need to worry about that anymore,
> >
> >  That's not what compatiblity means.  We can't just support
> >  latest-and-greatest userspace on latest-and-greatest kernels.
>
> Oh, I know that, that's not what I was getting at at all here, sorry if
> it came across that way.
>
> I wanted to know so we could go fix programs that are mucking around in
> these files, as odds are, the shouldn't be doing that in the first
> place.
>
> Like rpm, why would it matter what the memory in the system looks like?
>

I see, thanks.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

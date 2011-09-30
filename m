Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B065B9000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 18:46:10 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 30 Sep 2011 18:46:06 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8UMk4ME246462
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 18:46:04 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8UMk4I9028915
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 19:46:04 -0300
Subject: Re: [RFCv2][PATCH 1/4] break units out of string_get_size()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4E8634D3.2080504@zytor.com>
References: <20110930203219.60D507CB@kernel>  <4E8634D3.2080504@zytor.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 30 Sep 2011 15:46:01 -0700
Message-ID: <1317422761.16137.669.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, James.Bottomley@HansenPartnership.com

On Fri, 2011-09-30 at 14:29 -0700, H. Peter Anvin wrote:
> On 09/30/2011 01:32 PM, Dave Hansen wrote:
> > diff -puN lib/string_helpers.c~string_get_size-pow2 lib/string_helpers.c
> >  
> > +const char *units_10[] = { "B", "kB", "MB", "GB", "TB", "PB",
> > +			   "EB", "ZB", "YB", NULL};
> > +const char *units_2[] = {"B", "KiB", "MiB", "GiB", "TiB", "PiB",
> > +			 "EiB", "ZiB", "YiB", NULL };
> 
> These names are way too generic to be public symbols.

Ack, I managed to drop the static when I broke this out for the third
time. :)

> Another thing worth thinking about is whether or not the -B suffix
> should be part of these arrays.

... or the 'i' for that matter.

I'll give it a go.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

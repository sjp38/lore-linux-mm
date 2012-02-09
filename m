Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id B6A0F6B13F0
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 13:14:11 -0500 (EST)
Received: by dadv6 with SMTP id v6so2011990dad.14
        for <linux-mm@kvack.org>; Thu, 09 Feb 2012 10:14:11 -0800 (PST)
Date: Thu, 9 Feb 2012 10:13:39 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3/5] staging: zcache: replace xvmalloc with zsmalloc
Message-ID: <20120209181339.GA1360@kroah.com>
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1326149520-31720-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120209011326.GA2225@kroah.com>
 <4F33DE6F.80308@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F33DE6F.80308@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Brian King <brking@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Thu, Feb 09, 2012 at 08:55:43AM -0600, Seth Jennings wrote:
> On 02/08/2012 07:13 PM, Greg KH wrote:
> > On Mon, Jan 09, 2012 at 04:51:58PM -0600, Seth Jennings wrote:
> >> Replaces xvmalloc with zsmalloc as the persistent memory allocator
> >> for zcache
> >>
> >> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> > 
> > This patch no longer applies :(
> 
> Looks like my "staging: zcache: fix serialization bug in zv stats"
> patch didn't go in first.  There is an order dependency there.
> https://lkml.org/lkml/2012/1/9/403
> 
> Let me know if there is still an issue after applying that patch.

Hm, that one went into a different branch, that's what happened here.

Can you resend me that patch, and this one, so I can apply both to my
staging-next branch?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

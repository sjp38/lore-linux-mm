Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id E98EF6B0155
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 12:02:06 -0400 (EDT)
Received: by dakp5 with SMTP id p5so6886607dak.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 09:02:06 -0700 (PDT)
Date: Mon, 11 Jun 2012 09:01:40 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2] zsmalloc documentation
Message-ID: <20120611160140.GA23486@kroah.com>
References: <1339288874-2743-1-git-send-email-ngupta@vflare.org>
 <20120610004434.GA24894@localhost.localdomain>
 <4FD3EF26.7040108@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FD3EF26.7040108@vflare.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Sat, Jun 09, 2012 at 05:49:42PM -0700, Nitin Gupta wrote:
> On 06/09/2012 05:44 PM, Konrad Rzeszutek Wilk wrote:
> 
> > On Sat, Jun 09, 2012 at 05:41:14PM -0700, Nitin Gupta wrote:
> >> Documentation of various struct page fields
> >> used by zsmalloc.
> >>
> >> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
> >>
> >> Changes for v2:
> >> 	- Regroup descriptions as suggested by Seth
> >                                                ^^ - Konrad
> > 
> > Otherwise: Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > 
> 
> 
> Sorry about that, Konrad!
> Greg: Please let me know if I should resend the patch with corrected
> name in the changelog.

No need, I've fixed it up.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

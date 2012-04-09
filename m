Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 527B66B004A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 17:43:21 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so6619301pbc.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 14:43:20 -0700 (PDT)
Date: Mon, 9 Apr 2012 14:43:16 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: zsmalloc: fix memory leak
Message-ID: <20120409214316.GB535@kroah.com>
References: <1333376036-9841-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <d858d87f-6e07-4303-a9b3-e41ff93c8080@default>
 <4F7C7626.40506@linux.vnet.ibm.com>
 <4F83454A.3050007@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F83454A.3050007@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

A: No.
Q: Should I include quotations after my reply?

http://daringfireball.net/2007/07/on_top

On Mon, Apr 09, 2012 at 03:23:38PM -0500, Seth Jennings wrote:
> Hey Greg,
> 
> Haven't heard back from you on this patch and it needs to
> get into the 3.4 -rc releases ASAP.  It fixes a substantial
> memory leak when frontswap/zcache are enabled.
> 
> Let me know if you need me to repost.
> 
> The patch was sent on 4/2.

5 meager days ago, with a major holliday in the middle, not to mention a
conference as well.  That's bold.

It is not lost, is in my queue, and will get to Linus before 3.4-final
comes out, don't worry.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

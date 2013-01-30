Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 5CD276B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 12:20:10 -0500 (EST)
Date: Wed, 30 Jan 2013 18:21:59 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: zsmalloc: remove unused pool name
Message-ID: <20130130172159.GA24760@kroah.com>
References: <1359560212-8818-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <51093F43.2090503@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51093F43.2090503@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Wed, Jan 30, 2013 at 09:41:55AM -0600, Seth Jennings wrote:
> On 01/30/2013 09:36 AM, Seth Jennings wrote:> zs_create_pool()
> currently takes a name argument which is
> > never used in any useful way.
> >
> > This patch removes it.
> >
> > Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> 
> Crud, forgot the Acks...
> 
> Acked-by: Nitin Gupta <ngupta@vflare.org>
> Acked-by: Rik van Riel <riel@redhat.com>

{sigh} you just made me have to edit your patch by hand, you now owe me
a beer...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

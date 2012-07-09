Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 346436B006E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 10:47:48 -0400 (EDT)
Received: by yenr5 with SMTP id r5so12449461yen.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 07:47:47 -0700 (PDT)
Date: Mon, 9 Jul 2012 07:47:40 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 1/9] zcache: fix refcount leak
Message-ID: <20120709144740.GA3961@kroah.com>
References: <4FE97792.9020807@linux.vnet.ibm.com>
 <4FE977AA.2090003@linux.vnet.ibm.com>
 <20120626223651.GB6561@localhost.localdomain>
 <4FEA905A.4070207@linux.vnet.ibm.com>
 <20120627054456.GA18869@kroah.com>
 <4FFA7266.6090408@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FFA7266.6090408@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org

On Mon, Jul 09, 2012 at 01:55:50PM +0800, Xiao Guangrong wrote:
> On 06/27/2012 01:44 PM, Greg Kroah-Hartman wrote:
> > On Wed, Jun 27, 2012 at 12:47:22PM +0800, Xiao Guangrong wrote:
> >> On 06/27/2012 06:36 AM, Konrad Rzeszutek Wilk wrote:
> >>> On Tue, Jun 26, 2012 at 04:49:46PM +0800, Xiao Guangrong wrote:
> >>>> In zcache_get_pool_by_id, the refcount of zcache_host is not increased, but
> >>>> it is always decreased in zcache_put_pool
> >>>
> >>> All of the patches (1-9) look good to me, so please also
> >>> affix 'Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>'.
> >>>
> >>
> >> Thank you, Konrad!
> >>
> >> Greg, need i repost this patchset with Konrad's Reviewed-by?
> > 
> > No, I can add it when I apply them.
> > 
> 
> 
> Greg, sorry to trouble you but this patches stayed in the list for
> nearly two weeks. If it is ok, could you please apply them? :)

I have now returned from my vacation that I was on for parts of the last
two weeks and am digging out through my patch queue.  I'll get to these
soon, thanks for your patience.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

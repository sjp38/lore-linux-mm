Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 57A156B005C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 01:45:02 -0400 (EDT)
Received: by dakp5 with SMTP id p5so1045606dak.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 22:45:00 -0700 (PDT)
Date: Tue, 26 Jun 2012 22:44:56 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 1/9] zcache: fix refcount leak
Message-ID: <20120627054456.GA18869@kroah.com>
References: <4FE97792.9020807@linux.vnet.ibm.com>
 <4FE977AA.2090003@linux.vnet.ibm.com>
 <20120626223651.GB6561@localhost.localdomain>
 <4FEA905A.4070207@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FEA905A.4070207@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org

On Wed, Jun 27, 2012 at 12:47:22PM +0800, Xiao Guangrong wrote:
> On 06/27/2012 06:36 AM, Konrad Rzeszutek Wilk wrote:
> > On Tue, Jun 26, 2012 at 04:49:46PM +0800, Xiao Guangrong wrote:
> >> In zcache_get_pool_by_id, the refcount of zcache_host is not increased, but
> >> it is always decreased in zcache_put_pool
> > 
> > All of the patches (1-9) look good to me, so please also
> > affix 'Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>'.
> > 
> 
> Thank you, Konrad!
> 
> Greg, need i repost this patchset with Konrad's Reviewed-by?

No, I can add it when I apply them.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

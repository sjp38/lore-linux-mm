Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id C49C56B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 20:49:07 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id xb4so6849970pbc.29
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 17:49:07 -0700 (PDT)
Date: Mon, 18 Mar 2013 17:50:23 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 2/5] zero-filled pages awareness
Message-ID: <20130319005023.GA19891@kroah.com>
References: <1363314860-22731-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1363314860-22731-3-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363314860-22731-3-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 10:34:17AM +0800, Wanpeng Li wrote:
> Compression of zero-filled pages can unneccessarily cause internal
> fragmentation, and thus waste memory. This special case can be
> optimized.
> 
> This patch captures zero-filled pages, and marks their corresponding
> zcache backing page entry as zero-filled. Whenever such zero-filled
> page is retrieved, we fill the page frame with zero.
> 
> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

This patch applies with a bunch of fuzz, meaning it wasn't made against
the latest tree, which worries me.  Care to redo it, and the rest of the
series, and resend it?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

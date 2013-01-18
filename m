Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id D11106B0009
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 15:46:59 -0500 (EST)
Received: by mail-da0-f45.google.com with SMTP id w4so1780706dam.4
        for <linux-mm@kvack.org>; Fri, 18 Jan 2013 12:46:59 -0800 (PST)
Date: Fri, 18 Jan 2013 12:46:55 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/5] staging: zcache: rename ramster to zcache
Message-ID: <20130118204655.GC4788@kroah.com>
References: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
 <1358443597-9845-3-git-send-email-dan.magenheimer@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358443597-9845-3-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org

On Thu, Jan 17, 2013 at 09:26:34AM -0800, Dan Magenheimer wrote:
> In staging, rename ramster to zcache
> 
> The original zcache in staging was a "demo" version, and this new zcache
> is a significant rewrite.  While certain disagreements were being resolved,
> both "old zcache" and "new zcache" needed to reside in the staging tree
> simultaneously.  In order to minimize code change and churn, the newer
> version of zcache was temporarily merged into the "ramster" staging driver
> which, prior to that, had at one time heavily leveraged the older version
> of zcache.  So, recently, "new zcache" resided in the ramster directory.
> 
> Got that? No? Sorry, temporary political compromises are rarely pretty.
> 
> The older version of zcache is no longer being maintained and has now
> been removed from the staging tree.  So now the newer version of zcache
> can rightfully reclaim sole possession of the name "zcache".
> 
> This patch is simply a manual:
> 
>   # git mv drivers/staging/ramster drivers/staging/zcache
> 
> so the actual patch diff has been left out.
> 
> Because a git mv loses history, part of the original description of
> the changes between "old zcache" and "new zcache" is repeated below:

git mv does not loose history, it can handle it just fine.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

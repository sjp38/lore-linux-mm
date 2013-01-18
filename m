Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id D48BB6B000C
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 16:46:38 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id rl6so2362328pac.29
        for <linux-mm@kvack.org>; Fri, 18 Jan 2013 13:46:38 -0800 (PST)
Date: Fri, 18 Jan 2013 13:46:26 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH V2 0/5] staging: zcache: move new zcache code base from
 ramster
Message-ID: <20130118214626.GA11130@kroah.com>
References: <1358544267-9104-1-git-send-email-dan.magenheimer@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358544267-9104-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org

On Fri, Jan 18, 2013 at 01:24:22PM -0800, Dan Magenheimer wrote:
> [V2: no code changes, patchset now generated via git format-patch -M]
> 
> Hi Greg --
> 
> With "old zcache" now removed, we can now move "new zcache" from its
> temporary home (in drivers/staging/ramster) to reclaim sole possession
> of the name "zcache".
> 
> (Note that [PATCH 2/5] is just a git mv.)
> 
> This patchset should apply cleanly to staging-next.

Very nice, now applied, thanks.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

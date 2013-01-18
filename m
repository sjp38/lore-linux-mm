Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 644EB6B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 15:46:22 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id rp2so2264135pbb.29
        for <linux-mm@kvack.org>; Fri, 18 Jan 2013 12:46:21 -0800 (PST)
Date: Fri, 18 Jan 2013 12:46:17 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/5] staging: zcache: move new zcache code base from
 ramster
Message-ID: <20130118204617.GB4788@kroah.com>
References: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358443597-9845-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org

On Thu, Jan 17, 2013 at 09:26:32AM -0800, Dan Magenheimer wrote:
> Hi Greg --
> 
> With "old zcache" now removed, we can now move "new zcache" from its
> temporary home (in drivers/staging/ramster) to reclaim sole possession
> of the name "zcache".
> 
> Note that [PATCH 2/5] will require a manual:
> 
> # git mv drivers/staging/ramster drivers/staging/zcache

Ick, no, use git to generate the patch with rename style, and it will
create the tiny patch that does this which I can then apply (-M is the
option you want to 'git format-patch').

Care to resend this in that format so that I can apply this properly?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 0C57E6B0092
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 20:16:43 -0400 (EDT)
Received: by iagk10 with SMTP id k10so1763337iag.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 17:16:43 -0700 (PDT)
Date: Wed, 5 Sep 2012 17:14:09 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH V2 0/3] staging: ramster: move to new zcache2 code base
Message-ID: <20120906001409.GA25879@kroah.com>
References: <1346877901-12543-1-git-send-email-dan.magenheimer@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346877901-12543-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org

On Wed, Sep 05, 2012 at 01:44:58PM -0700, Dan Magenheimer wrote:
> [V2: rebased to apply to 20120905 staging-next, no other changes]
> 
> Hi Greg --
> 
> Please apply for staging-next for the 3.7 window to move ramster forward.
> Since AFAICT there have been no patches or contributions from others to
> drivers/staging/ramster since it was merged, this totally new version
> of ramster should not run afoul and the patches should apply to
> your staging-next tree as of 20120905.

All now applied, thanks.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

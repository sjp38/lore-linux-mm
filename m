Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 094AA6B005A
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 15:06:25 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so1571473pbb.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 12:06:25 -0700 (PDT)
Date: Wed, 5 Sep 2012 12:03:51 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/3] staging: ramster: remove old driver to prep for new
 base
Message-ID: <20120905190351.GA21131@kroah.com>
References: <1346366764-31717-1-git-send-email-dan.magenheimer@oracle.com>
 <1346366764-31717-2-git-send-email-dan.magenheimer@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346366764-31717-2-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org

On Thu, Aug 30, 2012 at 03:46:02PM -0700, Dan Magenheimer wrote:
> To prep for moving the ramster codebase on top of the new
> redesigned zcache2 codebase, we remove ramster (as well
> as its contained diverged v1.1 version of zcache) entirely.

This patch fails to apply on top of my staging-next tree :(

Care to refresh it, keep Konrad's ack, and resend all 3?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

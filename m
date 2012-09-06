Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id A3A116B008C
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 20:09:43 -0400 (EDT)
Received: by iagk10 with SMTP id k10so1757964iag.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 17:09:43 -0700 (PDT)
Date: Wed, 5 Sep 2012 17:07:08 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/3] staging: ramster: move to new zcache2 codebase
Message-ID: <20120906000708.GA13754@kroah.com>
References: <1346877901-12543-1-git-send-email-dan.magenheimer@oracle.com>
 <1346877901-12543-3-git-send-email-dan.magenheimer@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346877901-12543-3-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org

On Wed, Sep 05, 2012 at 01:45:00PM -0700, Dan Magenheimer wrote:
> [V2: rebased to apply to 20120905 staging-next, no other changes]

You do realize this patch introduces build warnings, right?

Hopefully you will fix that up soon (i.e. really soon...)

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

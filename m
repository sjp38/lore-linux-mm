Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 960316B0289
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 23:00:57 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3759561dak.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 20:00:56 -0700 (PDT)
Date: Fri, 22 Jun 2012 20:00:52 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 01/10] zcache: fix preemptable memory allocation in
 atomic context
Message-ID: <20120623030052.GA18440@kroah.com>
References: <4FE0392E.3090300@linux.vnet.ibm.com>
 <4FE36D32.3030408@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FE36D32.3030408@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Jun 21, 2012 at 01:51:30PM -0500, Seth Jennings wrote:
> I just noticed you sent this patchset to Andrew, but the
> staging tree is maintained by Greg.  You're going to want to
> send these patches to him.
> 
> Greg Kroah-Hartman <gregkh@linuxfoundation.org>

After this series is redone, right?  As it is, this submission didn't
look ok, so I'm hoping a second round is forthcoming...

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

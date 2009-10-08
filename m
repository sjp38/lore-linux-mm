Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0191E6B004D
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 19:09:56 -0400 (EDT)
Date: Thu, 8 Oct 2009 15:57:24 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 3/3] documentation
Message-ID: <20091008225724.GB22949@kroah.com>
References: <1253595414-2855-1-git-send-email-ngupta@vflare.org>
 <1253595414-2855-4-git-send-email-ngupta@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1253595414-2855-4-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, Marcin Slusarz <marcin.slusarz@gmail.com>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 22, 2009 at 10:26:54AM +0530, Nitin Gupta wrote:
> Short guide on how to setup and use ramzswap.

Can you also send a patch that adds a drivers/staging/ramzswap/TODO file
that follows the format of the other drivers/staging/*/TODO file
describing what is needed to be done to get the code merged into the
main kernel tree?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

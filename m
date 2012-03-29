Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 8EF8B6B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 10:10:39 -0400 (EDT)
Date: Thu, 29 Mar 2012 22:05:25 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm/memory_failure: Let the compiler add the function name
Message-ID: <20120329140525.GA10452@localhost>
References: <1332843450-7100-1-git-send-email-bp@amd64.org>
 <alpine.DEB.2.00.1203280018390.16201@chino.kir.corp.google.com>
 <20120328090909.GX22197@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120328090909.GX22197@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: David Rientjes <rientjes@google.com>, Borislav Petkov <bp@amd64.org>, LKML <linux-kernel@vger.kernel.org>, Borislav Petkov <borislav.petkov@amd.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Mar 28, 2012 at 11:09:09AM +0200, Andi Kleen wrote:
> > I agree with your change, but I'm not sure these should be pr_info() to 
> > start with, these seem more like debugging messages?  I can't see how 
> > they'd be useful in standard operation so could we just convert them to be 
> > debug instead?
> 
> Well it tells why the page recovery didn't work.
> 
> Memory recovery is a somewhat obscure path, so it's better to have
> full information.

Nod, and it won't disturb the users unless something really bad happens.

I'm fine with the patch, too.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

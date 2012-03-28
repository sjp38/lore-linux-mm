Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id DFFFD6B0044
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 05:09:11 -0400 (EDT)
Date: Wed, 28 Mar 2012 11:09:09 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm/memory_failure: Let the compiler add the function name
Message-ID: <20120328090909.GX22197@one.firstfloor.org>
References: <1332843450-7100-1-git-send-email-bp@amd64.org> <alpine.DEB.2.00.1203280018390.16201@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1203280018390.16201@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Borislav Petkov <bp@amd64.org>, LKML <linux-kernel@vger.kernel.org>, Borislav Petkov <borislav.petkov@amd.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org

> I agree with your change, but I'm not sure these should be pr_info() to 
> start with, these seem more like debugging messages?  I can't see how 
> they'd be useful in standard operation so could we just convert them to be 
> debug instead?

Well it tells why the page recovery didn't work.

Memory recovery is a somewhat obscure path, so it's better to have
full information.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id C46016B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:04:48 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so996610pbc.14
        for <linux-mm@kvack.org>; Tue, 14 Feb 2012 13:04:48 -0800 (PST)
Date: Tue, 14 Feb 2012 13:04:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Ensure that walk_page_range()'s start and end are
 page-aligned
In-Reply-To: <87pqdh1mvs.fsf@caffeine.danplanet.com>
Message-ID: <alpine.DEB.2.00.1202141259420.28450@chino.kir.corp.google.com>
References: <1328902796-30389-1-git-send-email-danms@us.ibm.com> <alpine.DEB.2.00.1202130211400.4324@chino.kir.corp.google.com> <87zkcm23az.fsf@caffeine.danplanet.com> <alpine.DEB.2.00.1202131350500.17296@chino.kir.corp.google.com>
 <87pqdh1mvs.fsf@caffeine.danplanet.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Smith <danms@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Feb 2012, Dan Smith wrote:

> I'd rather just make it always do the check in walk_page_range(). Does
> that sound reasonable?
> 

And do what if they're not?  What behavior are you trying to fix from the 
pagewalk code with respect to page-aligned addresses?  Any specific 
examples?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

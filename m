Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7D46B00BF
	for <linux-mm@kvack.org>; Fri,  2 Jan 2009 11:29:43 -0500 (EST)
Message-ID: <495E40EE.8080904@oracle.com>
Date: Fri, 02 Jan 2009 08:29:34 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Update of Documentation/ (VM sysctls)
References: <20081231212615.12868.97088.stgit@hermosa.site>	 <495D9222.1060306@oracle.com> <1230909901.3470.242.camel@hermosa.site>
In-Reply-To: <1230909901.3470.242.camel@hermosa.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Peter W. Morreale" <pmorreale@novell.com>
Cc: linux-kernel@vger.kernel.org, comandante@zaralinux.com, bb@ricochet.net, Rik van Riel <riel@nl.linux.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Peter W. Morreale wrote:
> On Thu, 2009-01-01 at 20:03 -0800, Randy Dunlap wrote:
>> Peter W Morreale wrote:
> 
>>> It assumes that patch: http://lkml.org/lkml/2008/12/31/219 has been applied.
>>> This is probably wrong since that patch is still being reviewed and not
>>> officially accepted as of this patch.  Not sure how to handle this at
>>> all.  
>> Yes, this patch should be done first/regardless of your other (pending) patch.
>>
> 
> Wait a sec...  
> 
> There is a patch interdependency here.
> 
> This patch includes the text for the two proposed sysctls.  If they are
> rejected, then this help text will refer to two non-existent sysctls.
> Minor issue compared to:
> 
> The pdflush sysctl patch was respun to include adding text (against the
> current vm.txt) for the new sysctls.  So that patch will fail to apply
> should this patch be added first. 
> 
> See what I mean? So what do I do?

Sorry about the confusion.  What I meant was that this patch's concept
(moving VM sysctls to Doc/sysctl/vm.txt) should be done first (without
the new pdflush pieces), then the new pdflush pieces should be done on
top of that first patch.  Is that clearer?

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

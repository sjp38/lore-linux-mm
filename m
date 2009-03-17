Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6AE6B004D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 17:08:07 -0400 (EDT)
Date: Tue, 17 Mar 2009 14:03:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 5493] mprotect usage causing slow system performance and
 freezing
Message-Id: <20090317140321.2e2cdd28.akpm@linux-foundation.org>
In-Reply-To: <20090317154724.80F57108040@picon.linux-foundation.org>
References: <bug-5493-27@http.bugzilla.kernel.org/>
	<20090317154724.80F57108040@picon.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: bugme-daemon@bugzilla.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Mar 2009 08:47:24 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=5493
> 
> 
> alan@lxorguk.ukuu.org.uk changed:
> 
>            What    |Removed                     |Added
> ----------------------------------------------------------------------------
>       KernelVersion|2.6.13                      |2.6.29
> 
> 
> 
> 
> ------- Comment #16 from alan@lxorguk.ukuu.org.uk  2009-03-17 08:47 -------
> Still causes significant indigestion in 2.6.29rc8

I don't think we know how to fix this :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

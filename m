Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 740076B0083
	for <linux-mm@kvack.org>; Thu, 17 May 2012 10:46:29 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3739560dak.14
        for <linux-mm@kvack.org>; Thu, 17 May 2012 07:46:28 -0700 (PDT)
Date: Thu, 17 May 2012 07:46:22 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
Message-ID: <20120517144622.GA27597@kroah.com>
References: <1337133919-4182-1-git-send-email-minchan@kernel.org>
 <1337133919-4182-3-git-send-email-minchan@kernel.org>
 <4FB4B29C.4010908@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FB4B29C.4010908@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, a.p.zijlstra@chello.nl, Nick Piggin <npiggin@gmail.com>

On Thu, May 17, 2012 at 05:11:08PM +0900, Minchan Kim wrote:
> Isn't there anyone for taking a time to review this patch? :)
> 
> On 05/16/2012 11:05 AM, Minchan Kim wrote:

<snip>

You want review within 24 hours for a staging tree patch for a feature
that no one uses?

That's very bold of you.  Please be realistic.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

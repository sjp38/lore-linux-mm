Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 0D4A96B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 14:38:35 -0400 (EDT)
Message-ID: <51E04D1E.8060303@parallels.com>
Date: Fri, 12 Jul 2013 22:38:22 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm: soft-dirty bits for user memory changes tracking
References: <517FED13.8090806@parallels.com> <517FED64.4020400@parallels.com> <51DEFD9E.7010703@mit.edu>
In-Reply-To: <51DEFD9E.7010703@mit.edu>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Matt Mackall <mpm@selenic.com>, Marcelo Tosatti <mtosatti@redhat.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 07/11/2013 10:46 PM, Andy Lutomirski wrote:
> 
> Sorry I'm late to the party -- I didn't notice this until the lwn
> article this week.
> 
> How does this get munmap + mmap right?  mremap marks things soft-dirty,
> but unmapping and remapping seems like it will result in the soft-dirty
> bit being cleared.  For that matter, won't this sequence also end up wrong:
> 
>  - clear_refs
>  - Write to mapping
>  - Page and pte evicted due to memory pressure
>  - Read from mapping -- clean page faulted back in
>  - pte soft-dirty is now clear ?!?

Yes, it looks like this problem exists. I'll look what can be done about
it, thank you.

> --Andy

Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

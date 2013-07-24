Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 10AC26B0034
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:52:31 -0400 (EDT)
Message-ID: <51F0225A.8040705@parallels.com>
Date: Wed, 24 Jul 2013 22:52:10 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Save soft-dirty bits on swapped pages
References: <20130724160826.GD24851@moon> <CALCETrXYnkonpBANnUuX+aJ=B=EYFwecZO27yrqcEU8WErz9DA@mail.gmail.com>
In-Reply-To: <CALCETrXYnkonpBANnUuX+aJ=B=EYFwecZO27yrqcEU8WErz9DA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On 07/24/2013 08:23 PM, Andy Lutomirski wrote:
> On Wed, Jul 24, 2013 at 9:08 AM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
>> Andy Lutomirski reported that in case if a page with _PAGE_SOFT_DIRTY
>> bit set get swapped out, the bit is getting lost and no longer
>> available when pte read back.
> 
> Potentially silly question (due to my completely lack of understanding
> of how swapping works in Linux): what about file-backed pages?

Strictly speaking file-backed mappings should also be fixed to keep the
soft-dirty bit, yes.

But in checkpoint-restore _shared_ file mappings are not of interest, as
all the data (changed or not) sits in the file and we just don't need to
take it into dump. If the file mapping of _private_, then pages, that are
written to become anonymous and occur in the swap cache and are handled
by this patch.

> (Arguably these would be best supported by filesystems instead of by
> the core vm, in which case it might make sense to drop soft-dirty
> support for these pages entirely.)
> 
> --Andy
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

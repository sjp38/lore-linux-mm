Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 238716B0044
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 19:09:24 -0400 (EDT)
Message-ID: <4F860F17.2090400@nod.at>
Date: Thu, 12 Apr 2012 01:09:11 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: swapoff() runs forever
References: <4F81F564.3020904@nod.at> <4F82752A.6020206@openvz.org> <4F82B6ED.2010500@nod.at> <alpine.LSU.2.00.1204091123380.1430@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1204091123380.1430@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>

Am 09.04.2012 20:40, schrieb Hugh Dickins:
> I've not seen any such issue in recent months (or years), but
> I've not been using UML either.  The most likely cause that springs
> to mind would be corruption of the vmalloc'ed swap map: that would
> be very likely to cause such a hang.

It does not look like a swap map corruption.
If I restart most user space processes swapoff() terminates fine.
Maybe it is a refcounting problem?

> You say "recent Linux kernels": I wonder what "recent" means.
> Is this something you can reproduce quickly and reliably enough
> to do a bisection upon?
>

I can reproduce the issue on any UML kernel.
The oldest I've tested was 2.6.20.
Therefore, bug was not introduced by me. B-)

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

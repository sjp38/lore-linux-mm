Message-ID: <480F8FE5.1030106@firstfloor.org>
Date: Wed, 23 Apr 2008 21:37:09 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [patch 18/18] hugetlb: my fixes 2
References: <20080423015302.745723000@nick.local0.net> <20080423015431.569358000@nick.local0.net> <480F13F5.9090003@firstfloor.org> <20080423184959.GD10548@us.ibm.com>
In-Reply-To: <20080423184959.GD10548@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

> they blatantly are ignoring information being provided by
> the kernel *and* are non-portable.

And? I'm sure both descriptions apply to significant parts of the
deployed userland, including software that deals with hugepages. You
should watch one of the Dave Jones' "why user space sucks" talks at some
point @)

> Sure, but that's an administrative choice and might be the default.
> We're already requiring extra effort to even use 1G pages, right, by
> specifying hugepagesz=1G, why does it matter if they also have to
> specify hugepagesz=2M.

Like I said earlier hugepagesz=2M is basically free, so there is no
reason to not have it even when you happen to have 1GB pages too.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

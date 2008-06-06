Message-ID: <484884EF.7070400@firstfloor.org>
Date: Fri, 06 Jun 2008 02:29:35 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
References: <20080603095956.781009952@amd.local0.net> <20080603100939.967775671@amd.local0.net> <1212515282.8505.19.camel@nimitz.home.sr71.net> <20080603182413.GJ20824@one.firstfloor.org> <1212519555.8505.33.camel@nimitz.home.sr71.net> <20080603205752.GK20824@one.firstfloor.org> <1212528479.7567.28.camel@nimitz.home.sr71.net> <4845DC72.5080206@firstfloor.org> <20080605231519.GD31534@us.ibm.com>
In-Reply-To: <20080605231519.GD31534@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

> I really don't want to get involved in this discussion, but let me just
> say: "Hugepages are *right now* strictly a harder-to-use optimization".
> libhugetlbfs helps quite a bit (in my opinion) as far as making
> hugepages easier to use. And Adam's dynamic pool work does as well. It's
> progress, slow and steady as it may be. I don't really appreciate the
> entire hugepage area being pigeon-holed into what you've experienced.

That is how Linus wanted hugepages to be done initially. Otherwise
we would have never gotten the separate hugetlbfs.

If you want a complete second VM that does everything in variable page
sizes then please redesign the original VM instead instead of recreating
all its code in mm/hugetlb.c. Thank you.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

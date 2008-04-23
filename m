Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3NLcbaw026922
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 17:38:37 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3NLcb9L313810
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 17:38:37 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3NLcaDD015533
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 17:38:36 -0400
Date: Wed, 23 Apr 2008 14:38:35 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 18/18] hugetlb: my fixes 2
Message-ID: <20080423213835.GA29372@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.569358000@nick.local0.net> <480F13F5.9090003@firstfloor.org> <20080423184959.GD10548@us.ibm.com> <480F8FE5.1030106@firstfloor.org> <20080423211136.GG10548@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423211136.GG10548@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [14:11:36 -0700], Nishanth Aravamudan wrote:
> On 23.04.2008 [21:37:09 +0200], Andi Kleen wrote:

<snip>

>  - How to deal with archs with many hugepage sizes available (IA64?) Do
>    we show all of them in /proc/meminfo?

Hrmm, IA64 here may be a red herring. As I understand it, with short
VHPT mode, there is one hugepage size for all of the hugepage region. In
which case, I think, we'd just make IA64 special in that the first
hugepagesz specified is the one used (and the only visible) or whatever
is the current native default with hugepages= is the one visible
(256M?). That is, IA64 will always only have one hugepagesize available
at run-time on a given boot, so we only need to show the one set of
files in /proc/meminfo. If IA64 moves to long VHPT mode, things would
need adjusting, I guess.

Clearly, we want to document this in kernel-parameters.txt :)

We also should bring in the sparc and sh maintainers, in case they want
to chime in on how things might be presented to those architectures, if
they want to move to multiple hugepage pools?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

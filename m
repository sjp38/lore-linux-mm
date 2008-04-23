Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3NM72w0005203
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 18:07:02 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3NM72FM184118
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 18:07:02 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3NM6qQp023846
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 18:06:52 -0400
Subject: Re: [patch 18/18] hugetlb: my fixes 2
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080423211136.GG10548@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net>
	 <20080423015431.569358000@nick.local0.net>
	 <480F13F5.9090003@firstfloor.org> <20080423184959.GD10548@us.ibm.com>
	 <480F8FE5.1030106@firstfloor.org>  <20080423211136.GG10548@us.ibm.com>
Content-Type: text/plain
Date: Wed, 23 Apr 2008 15:06:39 -0700
Message-Id: <1208988399.12718.12.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-04-23 at 14:11 -0700, Nishanth Aravamudan wrote:
> hugepagesz=16G hugepages=2 hugepages=20 hugepagesz=64k hugepages=40
> hugepagesz=16G hugepages=2 hugepagesz=16M hugepages=20 hugepagesz=64k
> hugepages=40
> 
>         allocates 2 16G hugepages, 20 16M hugepages and 40 64K
> hugepages
> 
> hugepagesz=64k hugepages=40
> 
>         allocates 40 64k hugepages

Following up after a chat on irc...

How about letting hugepages take a size argument:

	hugepages=33G

That would allocate 2 16G pages, then 1GB of 16M pages.  If there were
any remainder, then the rest in 64k pages.  Actually instantiating the
pages could be left to when the mounts are created.

I'm just not sure there's a really good reason to be specifying the
hugepagesz= at boot-time when we really don't need to commit to it at
that point.

That said, can ppc64 16G pages ever get used as 16M or 64K pages?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

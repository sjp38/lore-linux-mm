Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA06817
	for <linux-mm@kvack.org>; Fri, 31 Jan 2003 15:42:46 -0800 (PST)
Date: Fri, 31 Jan 2003 15:45:10 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030131154510.597e95fa.akpm@digeo.com>
In-Reply-To: <20030131.152328.101878010.davem@redhat.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
	<20030131.151310.25151725.davem@redhat.com>
	<20030131153626.403ae2e1.akpm@digeo.com>
	<20030131.152328.101878010.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"David S. Miller" <davem@redhat.com> wrote:
>
>    From: Andrew Morton <akpm@digeo.com>
>    Date: Fri, 31 Jan 2003 15:36:26 -0800
> 
>    "David S. Miller" <davem@redhat.com> wrote:
>    >
>    > Remind me why we can't just look at the PTE?
>    
>    Diktat ;)
>    
> I understand, but give _ME_ a way to use the pagetables if
> that is how things are implemented.  Don't force me to do
> a VMA lookup if I need not.

I did?  pmd_huge()/follow_huge_pmd().  Patch 2/4.

It might not be 100% appropriate for sparc64 pagetable representation - I
just guessed...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Mon, 03 Feb 2003 23:16:33 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: hugepage patches
Message-ID: <162820000.1044342992@[10.10.2.4]>
In-Reply-To: <m18yww1q5f.fsf@frodo.biederman.org>
References: <20030131151501.7273a9bf.akpm@digeo.com>
 <20030202025546.2a29db61.akpm@digeo.com>
 <20030202195908.GD29981@holomorphy.com>
 <20030202124943.30ea43b7.akpm@digeo.com><m1n0ld1jvv.fsf@frodo.biederman.org>
 <20030203132929.40f0d9c0.akpm@digeo.com><m1hebk1u8g.fsf@frodo.biederman.org>
 <20030204055012.GD1599@holomorphy.com> <m18yww1q5f.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>, William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> O.k.  Then the code definitely needs to handle shared mappings..

Why? we just divided the pagetable size by a factor of 1000, so
the problem is no longer really there ;-)
 
>> Well, in theory there's some kind of TLB benefit, but the only thing
>> ppl really care about is x86 pagetable structure gets rid of L3 space
>> entirely so you don't burn 12+GB of L3 pagetables for appserver loads.
> 
> I am with the group that actually cares more about the TLB benefit.
> For HPC loads there is really only one application per machine.  And with
> just one page table, the only real advantage is the more efficient use
> of the TLB.  

The reason we don't see it much is that we mostly have P3's which only
have 4 entries for large pages. P4's would be much easier to demonstrate
such things on, and I don't think we've really tried very hard on that with
hugetlbfs (earlier Java work by the research group showed impressive
improvements on an earlier implementation).

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

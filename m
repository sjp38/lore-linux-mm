Subject: Re: hugepage patches
References: <20030131151501.7273a9bf.akpm@digeo.com>
	<20030202025546.2a29db61.akpm@digeo.com>
	<20030202195908.GD29981@holomorphy.com>
	<20030202124943.30ea43b7.akpm@digeo.com>
	<m1n0ld1jvv.fsf@frodo.biederman.org>
	<20030203132929.40f0d9c0.akpm@digeo.com>
	<m1hebk1u8g.fsf@frodo.biederman.org>
	<20030204055012.GD1599@holomorphy.com>
	<m18yww1q5f.fsf@frodo.biederman.org>
	<162820000.1044342992@[10.10.2.4]>
	<m1znpcz0ag.fsf@frodo.biederman.org>
	<174080000.1044374131@[10.10.2.4]>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 05 Feb 2003 05:18:35 -0700
In-Reply-To: <174080000.1044374131@[10.10.2.4]>
Message-ID: <m1vfzyzzs4.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> writes:

> > Did I misunderstand what was meant by a massively shared mapping?
> > 
> > I can't imagine it being useful to guys like oracle without MAP_SHARED
> > support....
> 
> Create a huge shmem segment. and don't share the pagetables. Without large
> pages, it's an enormous waste of space in mindless duplication. With large
> pages, it's a much smaller waste of space (no PTEs) in mindless
> duplication. 
> Still not optimal, but makes the problem manageable.

And this is exactly the mmap(MAP_SHARED) case.  Where a single memory
segment is shared between multiple mm's. 

Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

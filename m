Date: Mon, 3 Feb 2003 21:50:12 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: hugepage patches
Message-ID: <20030204055012.GD1599@holomorphy.com>
References: <20030131151501.7273a9bf.akpm@digeo.com> <20030202025546.2a29db61.akpm@digeo.com> <20030202195908.GD29981@holomorphy.com> <20030202124943.30ea43b7.akpm@digeo.com> <m1n0ld1jvv.fsf@frodo.biederman.org> <20030203132929.40f0d9c0.akpm@digeo.com> <m1hebk1u8g.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1hebk1u8g.fsf@frodo.biederman.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@digeo.com>, davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 03, 2003 at 10:37:51PM -0700, Eric W. Biederman wrote:
> current->mm->mmap_sem really doesn't provide protection if there is
> a shared area between mappings in two different mm's.  Not a problem
> if the code is a private mapping but otherwise...
> Does hugetlbfs support shared mappings?  If it is exclusively
> for private mappings the code makes much more sense than I am
> thinking.

It's supposedly for massively shared mappings to reduce PTE overhead.
Well, in theory there's some kind of TLB benefit, but the only thing
ppl really care about is x86 pagetable structure gets rid of L3 space
entirely so you don't burn 12+GB of L3 pagetables for appserver loads.

-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

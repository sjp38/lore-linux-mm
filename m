Date: Fri, 31 Jan 2003 15:23:28 -0800 (PST)
Message-Id: <20030131.152328.101878010.davem@redhat.com>
Subject: Re: hugepage patches
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030131153626.403ae2e1.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
	<20030131.151310.25151725.davem@redhat.com>
	<20030131153626.403ae2e1.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@digeo.com
Cc: rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   "David S. Miller" <davem@redhat.com> wrote:
   >
   > Remind me why we can't just look at the PTE?
   
   Diktat ;)
   
I understand, but give _ME_ a way to use the pagetables if
that is how things are implemented.  Don't force me to do
a VMA lookup if I need not.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

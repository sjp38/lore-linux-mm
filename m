Date: Fri, 31 Jan 2003 15:48:13 -0800 (PST)
Message-Id: <20030131.154813.70082842.davem@redhat.com>
Subject: Re: hugepage patches
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030131154510.597e95fa.akpm@digeo.com>
References: <20030131153626.403ae2e1.akpm@digeo.com>
	<20030131.152328.101878010.davem@redhat.com>
	<20030131154510.597e95fa.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@digeo.com
Cc: rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   
   I did?  pmd_huge()/follow_huge_pmd().  Patch 2/4.
   
   It might not be 100% appropriate for sparc64 pagetable representation - I
   just guessed...
   
Oh I see, yes that appears it will work.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

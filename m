Date: Sun, 2 Feb 2003 12:17:59 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: hugepage patches
Message-ID: <20030202201759.GF29981@holomorphy.com>
References: <20030131151501.7273a9bf.akpm@digeo.com> <20030202025720.25bbf46d.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030202025720.25bbf46d.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 02, 2003 at 02:57:20AM -0800, Andrew Morton wrote:
> 12/4
> Fix hugetlb_vmtruncate_list()
> This function is quite wrong - has an "=" where it should have an "-" and
> confuses PAGE_SIZE and HPAGE_SIZE in its address and file offset arithmetic.

AFAICT the = typo and passing in a pgoff shifted the wrong amount were
the bogons here; maybe there's another one somewhere else.
Heavy-handed but correct.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA12483
	for <linux-mm@kvack.org>; Fri, 7 Feb 2003 14:00:39 -0800 (PST)
Date: Fri, 7 Feb 2003 14:00:15 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030207140015.0fe40a34.akpm@digeo.com>
In-Reply-To: <6315617889C99D4BA7C14687DEC8DB4E023D2E6C@fmsmsx402.fm.intel.com>
References: <6315617889C99D4BA7C14687DEC8DB4E023D2E6C@fmsmsx402.fm.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Seth, Rohit" <rohit.seth@intel.com>
Cc: davem@redhat.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Seth, Rohit" <rohit.seth@intel.com> wrote:
>
> Andrew,
> 
> New allocation of hugepages is an atomic operation.  Partial allocations
> of hugepages is not a possibility.

Yes it is?  If you ask hugetlb_prefault() to fault in four pages, and there
are only two pages available then it will instantiate just the two pages.

And updating i_size at the place where we add the page to pagecache makes
some sense..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

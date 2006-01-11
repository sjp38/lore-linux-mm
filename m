Date: Wed, 11 Jan 2006 14:52:02 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 2/2] hugetlb: synchronize alloc with page cache insert
Message-ID: <20060111225202.GE9091@holomorphy.com>
References: <1136920951.23288.5.camel@localhost.localdomain> <1137016960.9672.5.camel@localhost.localdomain> <1137018263.9672.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1137018263.9672.10.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 11, 2006 at 04:24:23PM -0600, Adam Litke wrote:
> My only concern is if I am using the correct lock for the job here.

->i_lock looks rather fishy. It may have been necessary when ->i_blocks
was used for nefarious purposes, but without ->i_blocks fiddling, it's
not needed unless I somehow missed the addition of some custom fields
to hugetlbfs inodes and their modifications by any of these functions.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

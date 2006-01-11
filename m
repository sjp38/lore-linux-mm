Date: Wed, 11 Jan 2006 15:24:56 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 2/2] hugetlb: synchronize alloc with page cache insert
Message-ID: <20060111232456.GF9091@holomorphy.com>
References: <1136920951.23288.5.camel@localhost.localdomain> <1137016960.9672.5.camel@localhost.localdomain> <1137018263.9672.10.camel@localhost.localdomain> <20060111225202.GE9091@holomorphy.com> <1137020606.9672.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1137020606.9672.16.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-01-11 at 14:52 -0800, William Lee Irwin III wrote:
>> ->i_lock looks rather fishy. It may have been necessary when ->i_blocks
>> was used for nefarious purposes, but without ->i_blocks fiddling, it's
>> not needed unless I somehow missed the addition of some custom fields
>> to hugetlbfs inodes and their modifications by any of these functions.

On Wed, Jan 11, 2006 at 05:03:25PM -0600, Adam Litke wrote:
> Nope, all the i_blocks stuff is gone.  I was just looking for a
> spin_lock for serializing all allocations for a particular hugeltbfs
> file and i_lock seemed to fit that bill.  It could be said, however,
> that the locking strategy used in the patch protects a section of code,
> not a data structure (which can be a bad idea).  Any thoughts on a less
> "fishy" locking strategy for this case?

That's not really something that needs to be synchronized per se. hugetlb
data structures need protection against concurrent modification, but
they have that from the functions you're calling.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

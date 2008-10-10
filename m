Subject: Re: [PATCH updated] ext4: Fix file fragmentation during large file
	write.
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <1223661776-20098-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1223661776-20098-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Fri, 10 Oct 2008 15:15:18 -0400
Message-Id: <1223666118.8209.23.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: cmm@us.ibm.com, tytso@mit.edu, sandeen@redhat.com, akpm@linux-foundation.org, hch@infradead.org, steve@chygwyn.com, npiggin@suse.de, mpatocka@redhat.com, linux-mm@kvack.org, inux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-10-10 at 23:32 +0530, Aneesh Kumar K.V wrote:
> The range_cyclic writeback mode use the address_space
> writeback_index as the start index for writeback. With
> delayed allocation we were updating writeback_index
> wrongly resulting in highly fragmented file. Number of
> extents reduced from 4000 to 27 for a 3GB file with
> the below patch.
> 
> The patch also removes the range_cont writeback mode
> added for ext4 delayed allocation. Instead we add
> two new flags in writeback_control which control
> the behaviour of write_cache_pages.
> 

I'm sorry, but I won't be able to test this until next wednesday.  In
general, I like the structure of it, and I can see this being useful for
other filesystems too.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

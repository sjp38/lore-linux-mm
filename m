Message-ID: <41E57038.6060701@sgi.com>
Date: Wed, 12 Jan 2005 12:45:12 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: page migration patchset
References: <Pine.LNX.4.44.0501121758180.2765-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.44.0501121758180.2765-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Robin Holt <holt@sgi.com>, Steve Longerbeam <stevel@mvista.com>, Andi Kleen <ak@muc.de>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, andrew morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 12 Jan 2005, Robin Holt wrote:
> 
>>On Tue, Jan 11, 2005 at 09:38:02AM -0600, Ray Bryant wrote:
>>
>>>Pages that are found to be swapped out would be handled as follows:
>>>Add the original node id to either the swap pte or the swp_entry_t.
>>>Swap in will be modified to allocate the page on the same node it
>>>came from.  Then, as part of migrate_process_pages, all that would
>>>be done for swapped out pages would be to change the "original node"
>>>field to point at the new node.
>>>
>>>However, I could probably do both steps (2) and (3) as part of the
>>>migrate_process_pages() call.
>>
>>I don't think we need to worry about the swap case.  Let's keep the
>>changes small and build when we see problems.  The normal swap
>>out/in mechanism should handle nearly all the page migration issues
>>you are concerned with.

At the moment, this discussion is moot (for my application at least).
For our workloads, we almost never swap, we are going to ignore migrating
swapped out pages until such a time that we see a performance need for same.

If that point ever comes, we will have to solve this problem then.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Sun, 6 Apr 2003 14:35:37 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030406213537.GO993@holomorphy.com>
References: <20030405024414.GP16293@dualathlon.random> <20030404192401.03292293.akpm@digeo.com> <20030405040614.66511e1e.akpm@digeo.com> <20030405163003.GD1326@dualathlon.random> <20030405132406.437b27d7.akpm@digeo.com> <20030405220621.GG1326@dualathlon.random> <20030405143138.27003289.akpm@digeo.com> <20030405231008.GI1326@dualathlon.random> <20030405175824.316efe90.akpm@digeo.com> <20030406144734.GN1326@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030406144734.GN1326@dualathlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@digeo.com>, mbligh@aracnet.com, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>>> Esepcially those sigbus in the current api
>>> would be more expensive than the regular paging internal to the VM and
>>> besides the signal it would generate flood of syscalls and kind of
>>> duplication of memory management inside the userspace.

On Sat, Apr 05, 2003 at 05:58:24PM -0800, Andrew Morton wrote:
>> That went away.  We now encode the file offset in the unmapped ptes, so the
>> kernel's fault handler can transparently reestablish the page.

On Sun, Apr 06, 2003 at 04:47:34PM +0200, Andrea Arcangeli wrote:
> if you put the file offset in the pte, you will break the max file
> offset that you can map, that at least should be recoded with a cookie
> like we do with the swap space

IIRC we just restricted the size of the file that can use the things to
avoid having to code quite so much up.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

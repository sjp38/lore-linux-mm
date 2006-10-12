Date: Thu, 12 Oct 2006 05:28:11 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/5] mm: fault vs invalidate/truncate race fix
Message-ID: <20061012032811.GA22558@wotan.suse.de>
References: <20061009140354.13840.71273.sendpatchset@linux.site> <20061009140414.13840.90825.sendpatchset@linux.site> <20061009211013.GP6485@ca-server1.us.oracle.com> <452AF312.1020207@yahoo.com.au> <20061011183404.GR6485@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061011183404.GR6485@ca-server1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fasheh <mark.fasheh@oracle.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 11, 2006 at 11:34:04AM -0700, Mark Fasheh wrote:
> On Tue, Oct 10, 2006 at 11:10:42AM +1000, Nick Piggin wrote:
> 
> The test I run is over here btw:
> 
> http://oss.oracle.com/projects/ocfs2-test/src/trunk/programs/multi_node_mmap/multi_mmap.c
> 
> I ran it with the following parameters:
> 
> mpirun -np 6 n1-3 ./multi_mmap -w mmap -r mmap -i 1000 -b 1024 /ocfs2/mmap/test4.txt

Thanks, I'll see if I can reproduce.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Sat, 5 Apr 2003 19:55:01 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: objrmap and vmtruncate
Message-Id: <20030405195501.028ca5d8.akpm@digeo.com>
In-Reply-To: <72740000.1049599406@[10.10.2.4]>
References: <20030404163154.77f19d9e.akpm@digeo.com>
	<12880000.1049508832@flay>
	<20030405024414.GP16293@dualathlon.random>
	<20030404192401.03292293.akpm@digeo.com>
	<20030405040614.66511e1e.akpm@digeo.com>
	<72740000.1049599406@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: andrea@suse.de, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> > The first test has 100 tasks, each of which has 100 vma's.  The 100 processes
> > modify their 100 vma's in a linear walk.  Total working set is 240MB
> > (slightly more than is available).
> > 
> > 	./rmap-test -l -i 10 -n 100 -s 600 -t 100 foo
> > 
> > 2.5.66-mm4:
> > 	15.76s user 86.91s system 33% cpu 5:05.07 total
> > 2.5.66-mm4+objrmap:
> > 	23.07s user 1143.26s system 87% cpu 22:09.81 total
> > 2.4.21-pre5aa2:
> > 	14.91s user 75.30s system 24% cpu 6:15.84 total
> 
> Isn't the intent to use sys_remap_file_pages for these sort of workloads
> anyway? In which case partial objrmap = rmap for these tests, so we're
> still OK?
> 

remap_file_pages() would work OK for this, yes.  Bit sad that an application
which runs OK on 2.4 would need recoding to work acceptably under 2.5 though.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

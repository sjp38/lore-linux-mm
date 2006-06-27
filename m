From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: slow hugetlb from 2.6.15
Date: Tue, 27 Jun 2006 12:23:10 -0700
Message-ID: <000001c69a1f$2171af00$e234030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <1151434062.8918.7.camel@dyn9047017100.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Badari Pulavarty' <pbadari@gmail.com>, stanojr@blackhole.websupport.sk
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote on Tuesday, June 27, 2006 11:48 AM
> On Tue, 2006-06-27 at 20:23 +0200, stanojr@blackhole.websupport.sk wrote:
> > hello
> > 
> > look at this benchmark http://www-unix.mcs.anl.gov/~kazutomo/hugepage/note.html
> > i try benchmark it on latest 2.6.17.1 (x86 and x86_64) and it slow like 2.6.16
> > on that web (in comparing to standard 4kb page)
> > its feature or bug ? 
> 
> Most likely, its due to new feature - demand paging for large pages :)
> Doing mlock() on mmaped area help ?


The original code measures not only the access time, but also page fault
path, that explains the huge difference with hugetlb between 2.6.12 and
2.6.16.  The former kernel prefaults, thus fault time is all done at mmap
call and is not counted at all in the timing measurement, while the latter
measurement includes faulting of hugetlb page.  Though it is a mystery to
see that faulting on hugetlb page is significantly longer than faulting a
normal page.

Yes, mlock() would take the variation out of the equation (if such call is
made outside the measurement).

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

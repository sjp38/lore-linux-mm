Date: Tue, 22 Oct 2002 14:01:55 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
Message-ID: <20021022140155.E20957@redhat.com>
References: <2629464880.1035240956@[10.10.2.3]> <Pine.LNX.4.44L.0210221405260.1648-100000@duckman.distro.conectiva> <20021022131930.A20957@redhat.com> <396790000.1035308200@flay> <20021022134501.C20957@redhat.com> <3DB59134.38AA41F6@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DB59134.38AA41F6@digeo.com>; from akpm@digeo.com on Tue, Oct 22, 2002 at 10:56:04AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 22, 2002 at 10:56:04AM -0700, Andrew Morton wrote:
> Have you reviewed the hugetlbfs and hugetlbpage-backed-shm patches?
> 
> That code is still requiring CAP_IPC_LOCK, although I suspect it
> would be better to allow hugetlbfs mmap to be purely administered
> by file permissions.

Can we delete the specialty syscalls now?

		-ben
-- 
"Do you seek knowledge in time travel?"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

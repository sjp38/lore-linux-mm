Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id KAA26808
	for <linux-mm@kvack.org>; Tue, 22 Oct 2002 10:56:07 -0700 (PDT)
Message-ID: <3DB59134.38AA41F6@digeo.com>
Date: Tue, 22 Oct 2002 10:56:04 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
References: <2629464880.1035240956@[10.10.2.3]> <Pine.LNX.4.44L.0210221405260.1648-100000@duckman.distro.conectiva> <20021022131930.A20957@redhat.com> <396790000.1035308200@flay> <20021022134501.C20957@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:
> 
> On Tue, Oct 22, 2002 at 10:36:40AM -0700, Martin J. Bligh wrote:
> > Bear in mind that large pages are neither swap backed or file backed
> > (vetoed by Linus), for starters. There are other large app problem scenarios
> > apart from Oracle ;-)
> 
> I think the fact that large page support doesn't support mmap for users
> that need it is utterly appauling; there are numerous places where it is
> needed.  The requirement for root-only access makes it useless for most
> people, especially in HPC environments where it is most needed as such
> machines are usually shared and accounts are non-priveledged.
> 

Have you reviewed the hugetlbfs and hugetlbpage-backed-shm patches?

That code is still requiring CAP_IPC_LOCK, although I suspect it
would be better to allow hugetlbfs mmap to be purely administered
by file permissions.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Tue, 22 Oct 2002 12:03:55 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
Message-ID: <408130000.1035313435@flay>
In-Reply-To: <20021022140155.E20957@redhat.com>
References: <2629464880.1035240956@[10.10.2.3]> <Pine.LNX.4.44L.0210221405260.1648-100000@duckman.distro.conectiva> <20021022131930.A20957@redhat.com> <396790000.1035308200@flay> <20021022134501.C20957@redhat.com> <3DB59134.38AA41F6@digeo.com> <20021022140155.E20957@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>, Andrew Morton <akpm@digeo.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> Have you reviewed the hugetlbfs and hugetlbpage-backed-shm patches?
>> 
>> That code is still requiring CAP_IPC_LOCK, although I suspect it
>> would be better to allow hugetlbfs mmap to be purely administered
>> by file permissions.
> 
> Can we delete the specialty syscalls now?

I was lead to believe that Linus designed them, so he may be emotionally attatched 
to them, but I think there would be few others that would cry over the loss ...

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

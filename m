Date: Tue, 22 Oct 2002 13:45:01 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
Message-ID: <20021022134501.C20957@redhat.com>
References: <2629464880.1035240956@[10.10.2.3]> <Pine.LNX.4.44L.0210221405260.1648-100000@duckman.distro.conectiva> <20021022131930.A20957@redhat.com> <396790000.1035308200@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <396790000.1035308200@flay>; from mbligh@aracnet.com on Tue, Oct 22, 2002 at 10:36:40AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 22, 2002 at 10:36:40AM -0700, Martin J. Bligh wrote:
> Bear in mind that large pages are neither swap backed or file backed
> (vetoed by Linus), for starters. There are other large app problem scenarios 
> apart from Oracle ;-)

I think the fact that large page support doesn't support mmap for users 
that need it is utterly appauling; there are numerous places where it is 
needed.  The requirement for root-only access makes it useless for most 
people, especially in HPC environments where it is most needed as such 
machines are usually shared and accounts are non-priveledged.

		-ben
-- 
"Do you seek knowledge in time travel?"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <20021022134501.C20957@redhat.com>
References: <2629464880.1035240956@[10.10.2.3]>
	<Pine.LNX.4.44L.0210221405260.1648-100000@duckman.distro.conectiva>
	<20021022131930.A20957@redhat.com> <396790000.1035308200@flay>
	<20021022134501.C20957@redhat.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Oct 2002 19:22:14 +0100
Message-Id: <1035310934.31917.124.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2002-10-22 at 18:45, Benjamin LaHaise wrote:
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

I was very suprised the large page crap went in, in the form it
currently exists. Merging pages makes sense, spotting and doing 4Mb page
allocations kernel side makes sense. The rest is very questionable

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

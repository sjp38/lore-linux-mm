Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <408130000.1035313435@flay>
References: <2629464880.1035240956@[10.10.2.3]>
	<Pine.LNX.4.44L.0210221405260.1648-100000@duckman.distro.conectiva>
	<20021022131930.A20957@redhat.com> <396790000.1035308200@flay>
	<20021022134501.C20957@redhat.com> <3DB59134.38AA41F6@digeo.com>
	<20021022140155.E20957@redhat.com>  <408130000.1035313435@flay>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Oct 2002 21:23:59 +0100
Message-Id: <1035318239.329.141.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Benjamin LaHaise <bcrl@redhat.com>, Andrew Morton <akpm@digeo.com>, Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2002-10-22 at 20:03, Martin J. Bligh wrote:

> > Can we delete the specialty syscalls now?
> 
> I was lead to believe that Linus designed them, so he may be emotionally attatched 
> to them, but I think there would be few others that would cry over the loss ...

You mean like the wonderfully pointless sys_readahead. The sooner these
calls go the better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

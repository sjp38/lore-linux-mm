Reply-To: Gerrit Huizenga <gh@us.ibm.com>
From: Gerrit Huizenga <gh@us.ibm.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch 
In-reply-to: Your message of 22 Oct 2002 21:23:59 BST.
             <1035318239.329.141.camel@irongate.swansea.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <10176.1035322404.1@us.ibm.com>
Date: Tue, 22 Oct 2002 14:33:24 -0700
Message-Id: <E1846eS-0002eC-00@w-gerrit2>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Benjamin LaHaise <bcrl@redhat.com>, Andrew Morton <akpm@digeo.com>, Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

In message <1035318239.329.141.camel@irongate.swansea.linux.org.uk>, > : Alan C
ox writes:
> On Tue, 2002-10-22 at 20:03, Martin J. Bligh wrote:
> 
> > > Can we delete the specialty syscalls now?
> > 
> > I was lead to believe that Linus designed them, so he may be emotionally attatched 
> > to them, but I think there would be few others that would cry over the loss ...
> 
> You mean like the wonderfully pointless sys_readahead. The sooner these
> calls go the better.

No, the other icky syscalls - the {alloc,free}_hugepages.

gerrit
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

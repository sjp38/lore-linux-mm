Reply-To: Gerrit Huizenga <gh@us.ibm.com>
From: Gerrit Huizenga <gh@us.ibm.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch 
In-reply-to: Your message of Tue, 22 Oct 2002 14:55:10 EDT.
             <20021022145510.H20957@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8421.1035314876.1@us.ibm.com>
Date: Tue, 22 Oct 2002 12:27:57 -0700
Message-Id: <E1844h3-0002Bt-00@w-gerrit2>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Martin J. Bligh" <mbligh@aracnet.com>, Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

In message <20021022145510.H20957@redhat.com>, > : Benjamin LaHaise writes:
> On Tue, Oct 22, 2002 at 11:47:37AM -0700, Gerrit Huizenga wrote:
> > Hmm.  Isn't it great that 2.6/3.0 will be stable soon and we can
> > start working on this for 2.7/3.1?
> 
> Sure, but we should delete the syscalls now and just use the filesystem 
> as the intermediate API.
> 
> 		-ben

That would be fine with me - we are only planning on people using
flags to shm*() or mmap(), not on the syscalls.  I thought Oracle
was the one heavily dependent on the icky syscalls.

gerrit
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

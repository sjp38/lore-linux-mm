Date: Tue, 22 Oct 2002 14:55:10 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
Message-ID: <20021022145510.H20957@redhat.com>
References: <1035310934.31917.124.camel@irongate.swansea.linux.org.uk> <E184442-0001zQ-00@w-gerrit2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E184442-0001zQ-00@w-gerrit2>; from gh@us.ibm.com on Tue, Oct 22, 2002 at 11:47:37AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit Huizenga <gh@us.ibm.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Martin J. Bligh" <mbligh@aracnet.com>, Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 22, 2002 at 11:47:37AM -0700, Gerrit Huizenga wrote:
> Hmm.  Isn't it great that 2.6/3.0 will be stable soon and we can
> start working on this for 2.7/3.1?

Sure, but we should delete the syscalls now and just use the filesystem 
as the intermediate API.

		-ben
-- 
"Do you seek knowledge in time travel?"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

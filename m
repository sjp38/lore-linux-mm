Date: Tue, 22 Oct 2002 15:29:43 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
Message-ID: <20021022152943.J20957@redhat.com>
References: <20021022145510.H20957@redhat.com> <E1844h3-0002Bt-00@w-gerrit2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1844h3-0002Bt-00@w-gerrit2>; from gh@us.ibm.com on Tue, Oct 22, 2002 at 12:27:57PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit Huizenga <gh@us.ibm.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Martin J. Bligh" <mbligh@aracnet.com>, Rik van Riel <riel@conectiva.com.br>, "Eric W. Biederman" <ebiederm@xmission.com>, Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 22, 2002 at 12:27:57PM -0700, Gerrit Huizenga wrote:
> That would be fine with me - we are only planning on people using
> flags to shm*() or mmap(), not on the syscalls.  I thought Oracle
> was the one heavily dependent on the icky syscalls.

You mean the wonderfully untested calls that never worked?  At least 
they'd tested and used Ingo's 2.4 based patches that made shmfs use 
4MB pages.

		-ben
-- 
"Do you seek knowledge in time travel?"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

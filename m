Date: Tue, 22 Oct 2002 13:36:49 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
Message-ID: <145460000.1035311809@baldur.austin.ibm.com>
In-Reply-To: <Pine.LNX.4.44L.0210221514430.1648-100000@duckman.distro.conectiva>
References: <Pine.LNX.4.44L.0210221514430.1648-100000@duckman.distro.conecti
 va>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@digeo.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Bill Davidsen <davidsen@tmr.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Tuesday, October 22, 2002 15:15:29 -0200 Rik van Riel
<riel@conectiva.com.br> wrote:

>> Or large pages.  I confess to being a little perplexed as to
>> why we're pursuing both.
> 
> I guess that's due to two things.
> 
> 1) shared pagetables can speed up fork()+exec() somewhat
> 
> 2) if we have two options that fix the Oracle problem,
>    there's a better chance of getting at least one of
>    the two merged ;)

And
  3) The current large page implementation is only for applications
     that want anonymous *non-pageable* shared memory.  Shared page
     tables reduce resource usage for any shared area that's mapped
     at a common address and is large enough to span entire pte pages.
     Since all pte pages are shared on a COW basis at fork time, children
     will continue to share all large read-only areas with their
     parent, eg large executables.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

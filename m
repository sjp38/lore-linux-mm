Date: Thu, 10 Oct 2002 17:21:30 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Fork timing numbers for shared page tables
Message-ID: <20021010172130.A11796@redhat.com>
References: <167610000.1034278338@baldur.austin.ibm.com> <3DA5D893.CDD2407C@digeo.com> <175360000.1034279947@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <175360000.1034279947@baldur.austin.ibm.com>; from dmccr@us.ibm.com on Thu, Oct 10, 2002 at 02:59:07PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 10, 2002 at 02:59:07PM -0500, Dave McCracken wrote:
> I don't know why exec introduces a small penalty for small tasks. I'm
> working on some optimizations that might help.

Compare against vfork() to see what kind of best case is possible, and 
how much of the overhead in small tasks is just in non-vm overhead.

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

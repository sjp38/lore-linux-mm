Date: Thu, 12 Jun 2003 10:50:41 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm6
Message-Id: <20030612105041.3e0320a7.akpm@digeo.com>
In-Reply-To: <1055435864.1466.9.camel@w-ming2.beaverton.ibm.com>
References: <20030607151440.6982d8c6.akpm@digeo.com>
	<3EE690AC.70500@us.ibm.com>
	<20030610201242.7fde819b.akpm@digeo.com>
	<1055435864.1466.9.camel@w-ming2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mingming Cao <cmm@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbadari@us.ibm.com
List-ID: <linux-mm.kvack.org>

Mingming Cao <cmm@us.ibm.com> wrote:
>
> 
> > Mingming Cao <cmm@us.ibm.com> wrote:
> > >
> > > I run 50 fsx tests on ext3 filesystem on 2.5.70-mm6 kernel. Serveral fsx 
> > >  tests hang with the status D, after the tests run for a while.  No oops, 
> > >  no error messages.  I found same problem on mm5, but 2.5.70 is fine.
>
> Sorry, the tests in 2.5.70 also failed, same problem.

OK.  It would be useful to test ext2 as well.

> On Tue, 2003-06-10 at 20:12, Andrew Morton wrote
> > If you could, please retest with "elevator=deadline"?
> > 
> Thanks for your feedback.
> 
> This time I got more fsx tests hang(about 25).  Before normally I saw 5
> or 10 tests fail. Here is the stack info.

Everything stuck waiting for IO to complete again.

Are you able to try a different qlogic driver?  Or a different HBA?

I tried to reproduce this but I don't have sufficient info.

How much memory does that machine have, and what fsx-linux command lines
are you using?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

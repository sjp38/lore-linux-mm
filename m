Date: Sat, 14 Jun 2003 01:01:39 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm9
Message-Id: <20030614010139.2f0f1348.akpm@digeo.com>
In-Reply-To: <3EEAD41B.2090709@us.ibm.com>
References: <20030613013337.1a6789d9.akpm@digeo.com>
	<3EEAD41B.2090709@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mingming Cao <cmm@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mingming Cao <cmm@us.ibm.com> wrote:
>
> Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.70/2.5.70-mm9/
> > 
> > 
> > Lots of fixes, lots of new things.
> >
> 
> Good news, Andrew. I run 50 fsx tests on ext3 filesystems on 2.5.70-mm9. 
>    The hang problem I used seen on 2.5.70-mm6 kernel is gone. The tests 
> runs fine for more than 9 hours. (Normally the problem will occur after 
> 7 hours run on 2.5.70-mm6 kernel).

OK.  I'm no statistician, but I'd be more comfortable with 24 hours..

> I am running the tests on 8 way PIII 700MHz, 4G memory, with 
> elevator=deadline.
> 

Was elevator=deadline observed to fail in earlier kernels?  If not then it
may be an anticipatory scheduler bug.  It certainly had all the appearances
of that.

So once you're really sure that elevator=deadline isn't going to fail,
could you please test elevator=as?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

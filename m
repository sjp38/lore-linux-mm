Subject: Re: 2.5.70-mm6
From: Mingming Cao <cmm@us.ibm.com>
In-Reply-To: <20030612105041.3e0320a7.akpm@digeo.com>
References: <20030607151440.6982d8c6.akpm@digeo.com>
	<3EE690AC.70500@us.ibm.com> <20030610201242.7fde819b.akpm@digeo.com>
	<1055435864.1466.9.camel@w-ming2.beaverton.ibm.com>
	<20030612105041.3e0320a7.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 12 Jun 2003 11:43:08 -0700
Message-Id: <1055443389.1518.86.camel@w-ming2.beaverton.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbadari@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 2003-06-12 at 10:50, Andrew Morton wrote:
> > > Mingming Cao <cmm@us.ibm.com> wrote:
> > Sorry, the tests in 2.5.70 also failed, same problem.
> 
> OK.  It would be useful to test ext2 as well.
I will try ext2.
 
> > On Tue, 2003-06-10 at 20:12, Andrew Morton wrote
> 
> Everything stuck waiting for IO to complete again.
> 
> Are you able to try a different qlogic driver?  Or a different HBA?
I will try.
>
> I tried to reproduce this but I don't have sufficient info.
>
Sorry about this.
 
> How much memory does that machine have, and what fsx-linux command lines
> are you using?
The tests were run on 8 way PIII 700MHZ, with 4G memory.  The fsx
command line is:

/root/fsx -R -W -r 4096 -w 4096 /mnt/mntxx/foo &


Thanks for looking at this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

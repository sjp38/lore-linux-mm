Date: Tue, 10 Jun 2003 20:12:42 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm6
Message-Id: <20030610201242.7fde819b.akpm@digeo.com>
In-Reply-To: <3EE690AC.70500@us.ibm.com>
References: <20030607151440.6982d8c6.akpm@digeo.com>
	<3EE690AC.70500@us.ibm.com>
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
> I run 50 fsx tests on ext3 filesystem on 2.5.70-mm6 kernel. Serveral fsx 
>  tests hang with the status D, after the tests run for a while.  No oops, 
>  no error messages.  I found same problem on mm5, but 2.5.70 is fine.
> 
>  Here is the stack info:

Thanks for this.

Everything is waiting on I/O.  It looks like either the device driver
failed or the IO scheduler got its state all screwed up.

Which device driver are you using there?

If you could, please retest with "elevator=deadline"?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Subject: Re: 2.6.0-test6-mm1
From: Daniel McNeil <daniel@osdl.org>
In-Reply-To: <20030928191038.394b98b4.akpm@osdl.org>
References: <20030928191038.394b98b4.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1064855347.23108.5.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Date: 29 Sep 2003 10:09:07 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2003-09-28 at 19:10, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test6/2.6.0-test6-mm1
> 
> 
> Lots of small things mainly.
> 
> The O_DIRECT-vs-buffers I/O locking changes appear to be complete, so testing
> attention on O_DIRECT workloads would be useful.
> 

OSDL's STP automatically ran dbt2 tests against 2.6.0-test6-mm1 this
morning (PLM patch #2174).

The dbt2 test uses raw devices and all the runs completed successfully.

Daniel


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

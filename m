Date: Mon, 29 Sep 2003 10:20:21 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test6-mm1
Message-Id: <20030929102021.76e96730.akpm@osdl.org>
In-Reply-To: <1064855347.23108.5.camel@ibm-c.pdx.osdl.net>
References: <20030928191038.394b98b4.akpm@osdl.org>
	<1064855347.23108.5.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel McNeil <daniel@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel McNeil <daniel@osdl.org> wrote:
>
> On Sun, 2003-09-28 at 19:10, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test6/2.6.0-test6-mm1
> > 
> > 
> > Lots of small things mainly.
> > 
> > The O_DIRECT-vs-buffers I/O locking changes appear to be complete, so testing
> > attention on O_DIRECT workloads would be useful.
> > 
> 
> OSDL's STP automatically ran dbt2 tests against 2.6.0-test6-mm1 this
> morning (PLM patch #2174).
> 
> The dbt2 test uses raw devices and all the runs completed successfully.

Well that's good, thanks.

Actually, it is O_DIRECT against regular files which needs the extra testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

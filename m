Subject: Re: 2.5.65-mm2
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <20030319012115.466970fd.akpm@digeo.com>
References: <20030319012115.466970fd.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 19 Mar 2003 12:51:28 -0700
Message-Id: <1048103489.1962.87.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2003-03-19 at 02:21, Andrew Morton wrote:
> 
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.65/2.5.65-mm2/
> 

I am seeing a significant degradation of interactivity under load with
recent -mm kernels.  The load is dbench on a reiserfs file system with
increasing numbers of clients.  The test machine is single PIII, IDE,
256MB memory, all kernels PREEMPT.

Specifying elevator=deadline improved the response of 2.5.65-mm2
somewhat, but it still eventually became intolerably slow with
sufficient load.

Interactivity tests consisted of switching between desktops with two
instances of Mozilla 1.3 on separate desktops, and Evolution 1.2.2 on
another desktop.  Additional tests included shaking the window and
wiggling the scrollbar.

The third and fourth columns list the number of dbench clients at which
interactivity becomes poor, or intolerable, defined here as getting a
response after:

good		less than 1 second
poor		seconds
intolerable	tens of seconds

kernel			interactivity under load (dbench clients)
			good	poor 	intolerable

2.5.65-bk		 56*
2.5.65-mm1		 <8	16	24
2.5.65-mm2		 <8	16	24
2.5.65-mm2 deadline	 <8	20	28

*2.5.65-bk was still performing very well at dbench 56.  I'll continue
to test up to 128 clients.

2.5.65-bk was updated with a bk pull this morning.

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

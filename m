Date: Wed, 19 Mar 2003 12:10:55 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.65-mm2
Message-Id: <20030319121055.685b9b8c.akpm@digeo.com>
In-Reply-To: <1048103489.1962.87.camel@spc9.esa.lanl.gov>
References: <20030319012115.466970fd.akpm@digeo.com>
	<1048103489.1962.87.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Steven Cole <elenstev@mesatop.com> wrote:
>
> On Wed, 2003-03-19 at 02:21, Andrew Morton wrote:
> > 
> > http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.65/2.5.65-mm2/
> > 
> 
> I am seeing a significant degradation of interactivity under load with
> recent -mm kernels.  The load is dbench on a reiserfs file system with
> increasing numbers of clients.  The test machine is single PIII, IDE,
> 256MB memory, all kernels PREEMPT.

(This email brought to you while running dbench 128 on ext3)

There's a pretty big reiserfs patch in -mm.  Are you able to whip up
an ext2 partition and see if that displays the same problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

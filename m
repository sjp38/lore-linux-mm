Date: Thu, 12 Jun 2003 16:08:18 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH] Fix vmtruncate race and distributed filesystem race
Message-ID: <150040000.1055452098@baldur.austin.ibm.com>
In-Reply-To: <20030612140014.32b7244d.akpm@digeo.com>
References: <133430000.1055448961@baldur.austin.ibm.com>
 <20030612134946.450e0f77.akpm@digeo.com>
 <20030612140014.32b7244d.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--On Thursday, June 12, 2003 14:00:14 -0700 Andrew Morton <akpm@digeo.com>
wrote:

> And this does require that ->nopage be entered with page_table_lock held,
> and that it drop it.

I think that's a worse layer violation than referencing inode in
do_no_page.  We shouldn't require that the filesystem layer mess with the
page_table_lock.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

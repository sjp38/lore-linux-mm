Date: Fri, 5 Sep 2003 14:50:56 -0400
From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] remap file pages MAP_NONBLOCK fix
Message-ID: <20030905185056.GA3598@gtf.org>
References: <1062786697.25345.253.camel@eecs-kilkenny.eecs.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1062786697.25345.253.camel@eecs-kilkenny.eecs.umich.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajesh Venkatasubramanian <vrajesh@eecs.umich.edu>
Cc: akpm@osdl.org, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 05, 2003 at 02:31:37PM -0400, Rajesh Venkatasubramanian wrote:
> Hi Andrew, Ingo,
> 
> The remap_file_pages system call with MAP_NONBLOCK flag does not
> install file-ptes when the required pages are not found in the
> page cache. Modify the populate functions to install file-ptes
> if the mapping is non-linear and the required pages are not found
> in the page cache.

Or we could just kill remap_file_pages(), because it's a PITA to
maintain and it has maybe 10 legitimate users in the entire world...

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Wed, 30 Apr 2003 20:22:15 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] remove unnecessary PAE pgd set
Message-ID: <20030501032215.GA20911@holomorphy.com>
References: <3EB05F61.5070404@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3EB05F61.5070404@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, Paul Larson <plars@linuxtestproject.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 30, 2003 at 04:42:25PM -0700, Dave Hansen wrote:
> With PAE on, there are only 4 PGD entries.  The kernel ones never
> change, so there is no need to copy them when a vmalloc fault occurs.
> This was this was causing problems with the split pmd patches, but it is
> still correct for mainline.
> Tested with and without PAE.  I ran it in a loop turning on and off 10
> swap partitions, which is what excited the original bug.
> http://bugme.osdl.org/show_bug.cgi?id=640

I suspect this set_pgd() should go away for non-PAE also.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

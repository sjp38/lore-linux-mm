Date: Mon, 27 May 2002 11:30:38 -0400
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: per VMA swapping function?
Message-ID: <20020527113038.B15343@redhat.com>
References: <3CF24557.5020405@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3CF24557.5020405@yahoo.com>; from gerykahn@yahoo.com on Mon, May 27, 2002 at 05:40:23PM +0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gery Kahn <gerykahn@yahoo.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2002 at 05:40:23PM +0300, Gery Kahn wrote:
> In 2.2.x VMA can have custom swapout func (vm_ops->swapout) (in file 
> mapping case) which swapping VMA pages to place other than swap partition.
> How is it implemented in 2.4.x?

Via common code.  See mm/vmscan.c.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

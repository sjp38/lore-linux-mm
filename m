Date: Wed, 10 Apr 2002 16:48:45 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] radix-tree pagecache for 2.4.19-pre5-ac3
Message-ID: <20020410234845.GB23767@holomorphy.com>
References: <20020407164439.GA5662@debian> <20020410205947.GG21206@holomorphy.com> <20020410220842.GA14573@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020410220842.GA14573@debian>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Art Haas <ahaas@neosoft.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2002 at 05:08:42PM -0500, Art Haas wrote:
> I think you've dropped an "=". Maybe this is the cause of the
> other trouble you were seeing?

I don't believe so. Just a vanilla 2.4.19-pre5-ac3 + your posted patch
+ corrected livelock fix (without it it livelocks instead) oopses at
fs/inode.c:515 within approximately 2 minutes:

    510 void clear_inode(struct inode *inode)
    511 {
    512         invalidate_inode_buffers(inode);
    513
    514         if (inode->i_data.nrpages)
    515                 BUG();
    516         if (!(inode->i_state & I_FREEING))
    517                 BUG();
    518         if (inode->i_state & I_CLEAR)
    519                 BUG();


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

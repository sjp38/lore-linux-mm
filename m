From: Daniel Phillips <phillips@arcor.de>
Subject: Re: Non-GPL export of invalidate_mmap_range
Date: Thu, 19 Feb 2004 15:56:49 -0500
References: <20040216190927.GA2969@us.ibm.com> <20040217124001.GA1267@us.ibm.com> <20040217161929.7e6b2a61.akpm@osdl.org>
In-Reply-To: <20040217161929.7e6b2a61.akpm@osdl.org>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200402191531.56618.phillips@arcor.de>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, paulmck@us.ibm.com
Cc: hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 17 February 2004 19:19, Andrew Morton wrote:
> I don't see any licensing issues with the patch because the filesystem
> which needs it clearly meets Linus's "this is not a derived work" criteria.
>
> And I don't see a technical problem with the export: given that we export
> truncate_inode_pages() it makes sense to also export the corresponding
> pagetable shootdown function.
>
> Yes, this is a sensitive issue.  Can we please evaluate it strictly
> according to technical and licensing considerations?
>
> Having said that, what concerns issues remain with Paul's patch?

Hi Andrew,

OpenGFS and Sistina GFS use zap_page_range directly, essentially doing the 
same as invalidate_mmap_range but skipping any vmas belonging to MAP_PRIVATE 
mmaps.  This avoids destroying data on anon pages.  GPFS and every other DFS 
have the same problem as far as I can see, and it isn't addressed by 
exporting invalidate_mmap_range as it stands.  Paul?

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

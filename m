Date: Tue, 22 Oct 2002 22:27:00 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
In-Reply-To: <3DB5A5BD.D3E00B4A@digeo.com>
Message-ID: <Pine.LNX.4.44.0210222220480.22282-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Oct 2002, Andrew Morton wrote:

> We seem to have lost a pte_page_unlock() from fremap.c:zap_pte()? I
> fixed up the ifdef tangle in there within the shpte-ng patch and then
> put the pte_page_unlock() back.

ok. I too fixed up the shpte #ifdef tangle in there as well, and it was
complex for no good reason, so i suspected that it was missing a line or
two.

> I also added a page_cache_release() to the error path in
> filemap_populate(), if install_page() failed.

hm, i somehow missed to add this, this was reported once already.

> The 2TB file size limit for mmap on non-PAE is a little worrisome. [...]

the limit is only there for 32-bit ptes on 32-bit platforms. 64-bit ptes
(both true 64-bit architectures and x86-PAE) has a ~64 zetabyte filesize
limit. I do not realistically believe that any 32-bit x86 box that is
connected to a larger than 2 TB disk array cannot possibly run a PAE
kernel. Just like you need PAE for more than 4 GB physical RAM. I find it
a bit worrisome that 32-bit x86 ptes can only support up to 4 GB of
physical RAM, but such is life :-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

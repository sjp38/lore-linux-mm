Content-Type: text/plain;
  charset="iso-8859-1"
From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: Re: 2.6.0-test9-mm3
Date: Fri, 14 Nov 2003 11:10:12 -0800
References: <20031112233002.436f5d0c.akpm@osdl.org> <98290000.1068836914@flay>
In-Reply-To: <98290000.1068836914@flay>
MIME-Version: 1.0
Content-Transfer-Encoding: 8BIT
Message-Id: <200311141110.12671.pbadari@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 14 November 2003 11:08 am, Martin J. Bligh wrote:
> > - Several ext2 and ext3 allocator fixes.  These need serious testing on
> > big SMP.
>
> OK, ext3 survived a swatting on the 16-way as well. It's still slow as
> snot, but it does work ;-) No changes from before, methinks.
>
> Diffprofile for kernbench (-j) from ext2 to ext3 on mm3
>
>      27022    16.3% total
>      24069    53.3% default_idle
>        583     2.4% page_remove_rmap
>        539   248.4% fd_install
>        478   388.6% __blk_queue_bounce

What driver are you using ? Why are you bouncing ?

Thanks,
Badari
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Fri, 14 Nov 2003 10:59:47 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test9-mm3
Message-Id: <20031114105947.641335f5.akpm@osdl.org>
In-Reply-To: <98290000.1068836914@flay>
References: <20031112233002.436f5d0c.akpm@osdl.org>
	<98290000.1068836914@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> 
> 
> > - Several ext2 and ext3 allocator fixes.  These need serious testing on big
> >   SMP.
> 
> OK, ext3 survived a swatting on the 16-way as well>

Great, thanks.

> It's still slow as snot, but it does work ;-)

I think SDET generates storms of metadata updates.  Making the journal
larger may help get that idle time down.

Probably the default journal size is too small nowadays.  Most tests seem
to run faster when it is enlarged.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

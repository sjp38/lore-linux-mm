Date: Sun, 28 Dec 2003 11:49:06 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-mm1
Message-Id: <20031228114906.5e9decdc.akpm@osdl.org>
In-Reply-To: <20031228105807.A19546@infradead.org>
References: <20031222211131.70a963fb.akpm@osdl.org>
	<20031228105807.A19546@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "viro@parcelfarce.linux.theplanet.co.uk" <viro@parcelfarce.linux.theplanet.co.uk>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@infradead.org> wrote:
>
> On Mon, Dec 22, 2003 at 09:11:31PM -0800, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test11/2.6.0-mm1/
> > 
> > 
> > Quite a lot of new material here.  It would be appreciated if people who have
> > significant patches in -mm could retest please.
> 
> BTW, could you please drop Al's RD* patches?  They change the entry points
> for block drivers and thus create some hassle for people hacking on out
> of tree block drivers, and obviously can't go into mainline as is.

Have you discussed this with him?  I was actually hoping to get those patches
merged up soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

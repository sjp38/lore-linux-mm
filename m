Date: Sun, 28 Dec 2003 10:58:07 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.0-mm1
Message-ID: <20031228105807.A19546@infradead.org>
References: <20031222211131.70a963fb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031222211131.70a963fb.akpm@osdl.org>; from akpm@osdl.org on Mon, Dec 22, 2003 at 09:11:31PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 22, 2003 at 09:11:31PM -0800, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test11/2.6.0-mm1/
> 
> 
> Quite a lot of new material here.  It would be appreciated if people who have
> significant patches in -mm could retest please.

BTW, could you please drop Al's RD* patches?  They change the entry points
for block drivers and thus create some hassle for people hacking on out
of tree block drivers, and obviously can't go into mainline as is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

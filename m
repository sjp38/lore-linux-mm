Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <18993.1179310769@redhat.com>
References: <20070318233008.GA32597093@melbourne.sgi.com>
	 <18993.1179310769@redhat.com>
Content-Type: text/plain
Date: Wed, 16 May 2007 20:09:19 +0800
Message-Id: <1179317360.2859.225.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-16 at 11:19 +0100, David Howells wrote:
> The start and end points passed to block_prepare_write() delimit the region of
> the page that is going to be modified.  This means that prepare_write()
> doesn't need to fill it in if the page is not up to date. 

Really? Is it _really_ going to be modified? Even if the pointer
userspace gave to write() is bogus, and is going to fault half-way
through the copy_from_user()?

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

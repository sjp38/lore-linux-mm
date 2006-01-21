Subject: Re: [rfc] split_page function to split higher order pages?
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20060121124053.GA911@wotan.suse.de>
References: <20060121124053.GA911@wotan.suse.de>
Content-Type: text/plain
Date: Sat, 21 Jan 2006 15:17:04 +0100
Message-Id: <1137853024.23974.0.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2006-01-21 at 13:40 +0100, Nick Piggin wrote:
> Hi,
> 
> Just wondering what people think of the idea of using a helper
> function to split higher order pages instead of doing it manually?

Maybe it's worth documenting that this is for kernel (or even
architecture) internal use only and that drivers really shouldn't be
doing this..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 26 Oct 2004 17:23:59 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] remove highmem_start_page
Message-Id: <20041026172359.3059edec.akpm@osdl.org>
In-Reply-To: <1098820614.5633.3.camel@localhost>
References: <1098820614.5633.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen <haveblue@us.ibm.com> wrote:
>
> +static inline int page_is_highmem(struct page *page)
> +{
> +	return PageHighMem(page);
> +}

(boggle).  Why not just use PageHighMem() directly?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

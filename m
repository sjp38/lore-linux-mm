Date: Wed, 6 Jun 2007 18:44:01 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 4/4] mm: variable length argument support
Message-ID: <20070606094401.GA10393@linux-sh.org>
References: <20070605150523.786600000@chello.nl> <20070605151203.790585000@chello.nl> <20070606013658.20bcbe2f.akpm@linux-foundation.org> <1181120061.7348.177.camel@twins> <20070606020651.19a89dca.akpm@linux-foundation.org> <1181122473.7348.188.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1181122473.7348.188.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 06, 2007 at 11:34:33AM +0200, Peter Zijlstra wrote:
> +static void flush_arg_page(struct linux_binprm *bprm, unsigned long pos,
> +		struct page *page)
> +{
> +	flush_cache_page(bprm->vma, pos, page_to_pfn(page));
> +}
> +
[snip]

> @@ -253,6 +305,17 @@ static void free_arg_pages(struct linux_
>  		free_arg_page(bprm, i);
>  }
>  
> +static void flush_arg_page(struct linux_binprm *bprm, unsigned long pos,
> +		struct page *page)
> +{
> +}
> +
inline?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

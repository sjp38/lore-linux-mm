Received: by wa-out-1112.google.com with SMTP id m28so1430661wag.8
        for <linux-mm@kvack.org>; Sun, 08 Jun 2008 21:48:31 -0700 (PDT)
Message-ID: <eada2a070806082148r51cc4417u97062017b522825e@mail.gmail.com>
Date: Sun, 8 Jun 2008 21:48:31 -0700
From: "Tim Pepper" <lnxninja@linux.vnet.ibm.com>
Subject: Re: [patch 3/7] mm: speculative page references
In-Reply-To: <20080605094825.699347000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080605094300.295184000@nick.local0.net>
	 <20080605094825.699347000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 5, 2008 at 2:43 AM,  <npiggin@suse.de> wrote:
> --- linux-2.6.orig/mm/vmscan.c
> +++ linux-2.6/mm/vmscan.c
> @@ -390,12 +390,10 @@ static pageout_t pageout(struct page *pa
>  }
>
>  /*
> - * Attempt to detach a locked page from its ->mapping.  If it is dirty or if
> - * someone else has a ref on the page, abort and return 0.  If it was
> - * successfully detached, return 1.  Assumes the caller has a single ref on
> - * this page.
> + * Save as remove_mapping, but if the page is removed from the mapping, it
> + * gets returned with a refcount of 0.

       ^^^^^^

Same as?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

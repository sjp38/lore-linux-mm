Date: Sun, 8 Jun 2008 12:05:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 19/21] powerpc: define support for 16G hugepages
Message-Id: <20080608120511.1b04c67a.akpm@linux-foundation.org>
In-Reply-To: <20080604113113.399344268@amd.local0.net>
References: <20080604112939.789444496@amd.local0.net>
	<20080604113113.399344268@amd.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 04 Jun 2008 21:29:58 +1000 npiggin@suse.de wrote:

> +		switch (HPAGE_SHIFT) {
> +		case PAGE_SHIFT_64K:
> +		    /* We only allow 64k hpages with 4k base page,
> +		     * which was checked above, and always put them
> +		     * at the PMD */
> +		    hugepte_shift = PMD_SHIFT;
> +		    break;

eww, what's with the tabspacespacespacespace?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Sun, 28 Aug 2005 23:02:31 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH 2/6] CART Implementation
In-Reply-To: <20050827220300.688094000@twins>
Message-ID: <Pine.LNX.4.63.0508282301390.13831@cuia.boston.redhat.com>
References: <20050827215756.726585000@twins> <20050827220300.688094000@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 27 Aug 2005, a.p.zijlstra@chello.nl wrote:

> +static void bucket_stats(struct nr_bucket * nr_bucket, int * b1, int * b2)
> +{
> +	unsigned int i, b[2] = {0, 0};
> +	for (i = 0; i < 2; ++i) {
> +		unsigned int j = nr_bucket->hand[i];
> +		do
> +		{
> +			u32 *slot = &nr_bucket->slot[j];
> +			if (!!(GET_FLAGS(*slot) & NR_list) != !!i)
> +				break;
> +
> +			j = GET_INDEX(*slot);
> +			++b[i];
> +		} while (j != nr_bucket->hand[i]);

Does this properly skip empty slots ?

Remember that a page that got paged in leaves a zeroed
out slot in the bucket...

-- 
All Rights Reversed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

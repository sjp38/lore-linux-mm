Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33D11C4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 13:42:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D325E208C0
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 13:42:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ellerman.id.au header.i=@ellerman.id.au header.b="DTh4Ce12"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D325E208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DA336B02BA; Wed, 18 Sep 2019 09:42:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78BC26B02BC; Wed, 18 Sep 2019 09:42:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 652346B02BD; Wed, 18 Sep 2019 09:42:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0111.hostedemail.com [216.40.44.111])
	by kanga.kvack.org (Postfix) with ESMTP id 437FB6B02BA
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 09:42:29 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id DBAAA8243760
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:42:28 +0000 (UTC)
X-FDA: 75948155976.01.worm65_1587a40fef61c
X-HE-Tag: worm65_1587a40fef61c
X-Filterd-Recvd-Size: 11787
Received: from ozlabs.org (ozlabs.org [203.11.71.1])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 13:42:27 +0000 (UTC)
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 46YLkl0wyVz9sNf;
	Wed, 18 Sep 2019 23:42:23 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=ellerman.id.au;
	s=201909; t=1568814143;
	bh=EQhpXiyS7KsF9+1/ZmJXSVIeeHg4lTiTEFNaX4UOsRw=;
	h=From:To:Subject:In-Reply-To:References:Date:From;
	b=DTh4Ce12h8bVFHwFoywR4rObsIxASu3Ej/EV8aPsSG5CALE9WCoaiwT2pBnMzKvrM
	 uLRO3cJe9eo/+mFPYPzmVFLy6hrcSMkoM4rR+flnSB0dAhK/FVWV7k8jNIeKN+DYI9
	 XBeoOgotEOrw3m+RRDCW3Gy9TcizH12aHP4yvCxO0RXy+CkqMH7pUdYp8+9P4D2qVp
	 V3dpuQ96vv18VBp5SFDjq6jZTXeI1JYQn5Yhlgwzvts+yTBsz246VQAxEzjq0iLMYj
	 rBc/iGrJSwtB+rIia5nMJreISpqUkAxL6Tm4NlwEceStt4z7voWz9GL08MfrQMZRR/
	 1MPlRaM2cTfkQ==
From: Michael Ellerman <mpe@ellerman.id.au>
To: Laurent Dufour <ldufour@linux.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, aneesh.kumar@linux.ibm.com, npiggin@gmail.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 1/2] powperc/mm: read TLB Block Invalidate Characteristics
In-Reply-To: <20190916095543.17496-2-ldufour@linux.ibm.com>
References: <20190916095543.17496-1-ldufour@linux.ibm.com> <20190916095543.17496-2-ldufour@linux.ibm.com>
Date: Wed, 18 Sep 2019 23:42:21 +1000
Message-ID: <87zhj1vhz6.fsf@mpe.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Laurent,

Comments below ...

Laurent Dufour <ldufour@linux.ibm.com> writes:
> The PAPR document specifies the TLB Block Invalidate Characteristics which
> tells for each couple segment base page size, actual page size, the size of
                 ^
                 "pair of" again

> the block the hcall H_BLOCK_REMOVE is supporting.
                                     ^
                                     "supports" is fine.

> These characteristics are loaded at boot time in a new table hblkr_size.
> The table is appart the mmu_psize_def because this is specific to the
               ^
               "separate from"

> pseries architecture.
          ^
          platform
>
> A new init service, pseries_lpar_read_hblkr_characteristics() is added to
             ^
             function

> read the characteristics. In that function, the size of the buffer is set
> to twice the number of known page size, plus 10 bytes to ensure we have
> enough place. This new init function is called from pSeries_setup_arch().
         ^
         space
>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> ---
>  .../include/asm/book3s/64/tlbflush-hash.h     |   1 +
>  arch/powerpc/platforms/pseries/lpar.c         | 138 ++++++++++++++++++
>  arch/powerpc/platforms/pseries/setup.c        |   1 +
>  3 files changed, 140 insertions(+)
>
> diff --git a/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h b/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h
> index 64d02a704bcb..74155cc8cf89 100644
> --- a/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h
> +++ b/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h
> @@ -117,4 +117,5 @@ extern void __flush_hash_table_range(struct mm_struct *mm, unsigned long start,
>  				     unsigned long end);
>  extern void flush_tlb_pmd_range(struct mm_struct *mm, pmd_t *pmd,
>  				unsigned long addr);
> +extern void pseries_lpar_read_hblkr_characteristics(void);

This doesn't need "extern", and also should go in
arch/powerpc/platforms/pseries/pseries.h as it's local to that directory.

You're using "hblkr" in a few places, can we instead make it "hblkrm" -
"rm" is a well known abbreviation for "remove".


> diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platforms/pseries/lpar.c
> index 36b846f6e74e..98a5c2ff9a0b 100644
> --- a/arch/powerpc/platforms/pseries/lpar.c
> +++ b/arch/powerpc/platforms/pseries/lpar.c
> @@ -56,6 +56,15 @@ EXPORT_SYMBOL(plpar_hcall);
>  EXPORT_SYMBOL(plpar_hcall9);
>  EXPORT_SYMBOL(plpar_hcall_norets);
>  
> +/*
> + * H_BLOCK_REMOVE supported block size for this page size in segment who's base
> + * page size is that page size.
> + *
> + * The first index is the segment base page size, the second one is the actual
> + * page size.
> + */
> +static int hblkr_size[MMU_PAGE_COUNT][MMU_PAGE_COUNT];

Can you make that __ro_after_init, it goes at the end, eg:

static int hblkr_size[MMU_PAGE_COUNT][MMU_PAGE_COUNT] __ro_after_init;

> @@ -1311,6 +1320,135 @@ static void do_block_remove(unsigned long number, struct ppc64_tlb_batch *batch,
>  		(void)call_block_remove(pix, param, true);
>  }
>  
> +/*
> + * TLB Block Invalidate Characteristics These characteristics define the size of
                                           ^
                                           newline before here?

> + * the block the hcall H_BLOCK_REMOVE is able to process for each couple segment
> + * base page size, actual page size.
> + *
> + * The ibm,get-system-parameter properties is returning a buffer with the
> + * following layout:
> + *
> + * [ 2 bytes size of the RTAS buffer (without these 2 bytes) ]
                                         ^
                                         "excluding"

> + * -----------------
> + * TLB Block Invalidate Specifiers:
> + * [ 1 byte LOG base 2 of the TLB invalidate block size being specified ]
> + * [ 1 byte Number of page sizes (N) that are supported for the specified
> + *          TLB invalidate block size ]
> + * [ 1 byte Encoded segment base page size and actual page size
> + *          MSB=0 means 4k segment base page size and actual page size
> + *          MSB=1 the penc value in mmu_psize_def ]
> + * ...
> + * -----------------
> + * Next TLB Block Invalidate Specifiers...
> + * -----------------
> + * [ 0 ]
> + */
> +static inline void __init set_hblk_bloc_size(int bpsize, int psize,
> +					     unsigned int block_size)

"static inline" and __init are sort of contradictory.

Just make it "static void __init" and the compiler will inline it
anyway, but if it decides not to the section will be correct.

This one uses "hblk"? Should it be set_hblkrm_block_size() ?

> +{
> +	if (block_size > hblkr_size[bpsize][psize])
> +		hblkr_size[bpsize][psize] = block_size;
> +}
> +
> +/*
> + * Decode the Encoded segment base page size and actual page size.
> + * PAPR specifies with bit 0 as MSB:
> + *   - bit 0 is the L bit
> + *   - bits 2-7 are the penc value

Can we just convert those to normal bit ordering for the comment, eg:

 PAPR specifies:
   - bit 7 is the L bit
   - bits 0-5 are the penc value

> + * If the L bit is 0, this means 4K segment base page size and actual page size
> + * otherwise the penc value should be readed.
                                         ^
                                         "read" ?
> + */
> +#define HBLKR_L_BIT_MASK	0x80

"HBLKRM_L_MASK" would do I think?

> +#define HBLKR_PENC_MASK		0x3f
> +static inline void __init check_lp_set_hblk(unsigned int lp,
> +					    unsigned int block_size)
> +{
> +	unsigned int bpsize, psize;
> +

One blank line is sufficient :)

> +
> +	/* First, check the L bit, if not set, this means 4K */
> +	if ((lp & HBLKR_L_BIT_MASK) == 0) {
> +		set_hblk_bloc_size(MMU_PAGE_4K, MMU_PAGE_4K, block_size);
> +		return;
> +	}
> +
> +	lp &= HBLKR_PENC_MASK;
> +	for (bpsize = 0; bpsize < MMU_PAGE_COUNT; bpsize++) {
> +		struct mmu_psize_def *def =  &mmu_psize_defs[bpsize];
                                            ^
                                            stray space there
> +
> +		for (psize = 0; psize < MMU_PAGE_COUNT; psize++) {
> +			if (def->penc[psize] == lp) {
> +				set_hblk_bloc_size(bpsize, psize, block_size);
> +				return;
> +			}
> +		}
> +	}
> +}
> +
> +#define SPLPAR_TLB_BIC_TOKEN		50
> +#define SPLPAR_TLB_BIC_MAXLENGTH	(MMU_PAGE_COUNT*2 + 10)

The +10 is just a guess I think?

If I'm counting right that ends up as 42 bytes, which is not much at
all. You could probably just make it a cache line, 128 bytes, which
should be plenty of space?

> +void __init pseries_lpar_read_hblkr_characteristics(void)
> +{
> +	int call_status;

This should be grouped with the other ints below on one line.

> +	unsigned char local_buffer[SPLPAR_TLB_BIC_MAXLENGTH];
> +	int len, idx, bpsize;
> +
> +	if (!firmware_has_feature(FW_FEATURE_BLOCK_REMOVE)) {
> +		pr_info("H_BLOCK_REMOVE is not supported");

That's going to trigger on a lot of older machines, and all KVM VMs, so
just return silently.

> +		return;
> +	}
> +
> +	memset(local_buffer, 0, SPLPAR_TLB_BIC_MAXLENGTH);

Here you memset the whole buffer ...

> +	spin_lock(&rtas_data_buf_lock);
> +	memset(rtas_data_buf, 0, RTAS_DATA_BUF_SIZE);
> +	call_status = rtas_call(rtas_token("ibm,get-system-parameter"), 3, 1,
> +				NULL,
> +				SPLPAR_TLB_BIC_TOKEN,
> +				__pa(rtas_data_buf),
> +				RTAS_DATA_BUF_SIZE);
> +	memcpy(local_buffer, rtas_data_buf, SPLPAR_TLB_BIC_MAXLENGTH);

But then here you memcpy over the entire buffer, making the memset above
unnecessary.

> +	local_buffer[SPLPAR_TLB_BIC_MAXLENGTH - 1] = '\0';
> +	spin_unlock(&rtas_data_buf_lock);
> +
> +	if (call_status != 0) {
> +		pr_warn("%s %s Error calling get-system-parameter (0x%x)\n",
> +			__FILE__, __func__, call_status);

__FILE__ and __func__ is pretty verbose for what should be a rare case
(I realise you copied that from existing code).

		pr_warn("Error calling get-system-parameter(%d, ...) (0x%x)\n",
                        SPLPAR_TLB_BIC_TOKEN, call_status);

Should do I think?

> +		return;
> +	}
> +
> +	/*
> +	 * The first two (2) bytes of the data in the buffer are the length of
> +	 * the returned data, not counting these first two (2) bytes.
> +	 */
> +	len = local_buffer[0] * 256 + local_buffer[1] + 2;

This took me a minute to parse. I guess I was expecting something more
like:
	len = be16_to_cpu(local_buffer) + 2;

??

> +	if (len >= SPLPAR_TLB_BIC_MAXLENGTH) {

I think it's allowed for len to be == SPLPAR_TLB_BIC_MAXLENGTH isn't it?

> +		pr_warn("%s too large returned buffer %d", __func__, len);
> +		return;
> +	}
> +
> +	idx = 2;
> +	while (idx < len) {
> +		unsigned int block_size = local_buffer[idx++];

This is a little subtle, local_buffer is char, so no endian issue, but
you're loading that into an unsigned int which makes it look like there
should be an endian swap.

Maybe instead do:
		u8 block_shift = local_buffer[idx++];
                u32 block_size;

		if (!block_shift)
                	break;

		block_size = 1 << block_shift;

??

> +		unsigned int npsize;
> +
> +		if (!block_size)
> +			break;
> +
> +		block_size = 1 << block_size;
> +
> +		for (npsize = local_buffer[idx++];  npsize > 0; npsize--)
> +			check_lp_set_hblk((unsigned int) local_buffer[idx++],
> +					  block_size);

This could overflow if npsize is too big. I think you can just add
"&& idx < len" to the for condition to make it safe?

> +	}
> +
> +	for (bpsize = 0; bpsize < MMU_PAGE_COUNT; bpsize++)
> +		for (idx = 0; idx < MMU_PAGE_COUNT; idx++)
> +			if (hblkr_size[bpsize][idx])
> +				pr_info("H_BLOCK_REMOVE supports base psize:%d psize:%d block size:%d",
> +					bpsize, idx, hblkr_size[bpsize][idx]);

I think this is probably too verbose, except for debugging. Probably
just remove it?

cheers


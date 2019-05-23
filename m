Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B071C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:00:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24FE1217D7
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 19:00:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="UKb2x9rl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24FE1217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C314F6B0282; Thu, 23 May 2019 15:00:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB8956B028D; Thu, 23 May 2019 15:00:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0AAB6B028F; Thu, 23 May 2019 15:00:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 669A46B0282
	for <linux-mm@kvack.org>; Thu, 23 May 2019 15:00:38 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id u11so4043877plz.22
        for <linux-mm@kvack.org>; Thu, 23 May 2019 12:00:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2ANG0ElVZ/rPDPxKXuA88IUbN3whPdkvGrD4K4bBAhg=;
        b=hixCYNXM/E/4p7s17OUwyaKhPrUgetLar4cbPwQr+Iq7P+h/7euwgNW0LrZtLslCsU
         aQQeps9qaN0+LFtrQL1lm0EFVDajqRYY40yqc2Q9pngqocjXibLEoCpITC224JDAkP62
         XqVz7hHHVP/S2bxx/XYAxjMHnefSlAH/nu4No24MzVgN1T/FIeCVST44w342WKHqFNM8
         6Kbw3KvFp3QyFI0700S+klkf9Om/j3cIvRMfPq5AQ4GkQLrS5J/I8BsM3U85J7OmVnCq
         eAc2i0JHawEr1u5rGq8/fAhDnBiPADH9PKCay4PIdQdB+roRJwu0CRfN7PgWsDb8+hA7
         B9oA==
X-Gm-Message-State: APjAAAV0Uyt9D77d8W61+L5ZWqPFBQ5KBuNPRCE5aDUJmGBSxJV+OldP
	H1iWQwkIr7c+6oAKDMfvFsNVsGAJC+70+5dzWXYhYQDWE8W99fwilfHLED739nUImGbp6VosnTp
	tlF/U1Zt7YGs0x1pYznPP0EaP55omPPPInAuc6LurP/bzXXdCwgdHsM3bhYX2N5qiTA==
X-Received: by 2002:a62:ee04:: with SMTP id e4mr42095863pfi.232.1558638037766;
        Thu, 23 May 2019 12:00:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxD17+xmPzSK3rp3l+RW9WWA9OvXRhRe9hF4dtURmmYjLRak17L+4IgpzjKVAotrmYZG+9R
X-Received: by 2002:a62:ee04:: with SMTP id e4mr42095708pfi.232.1558638036620;
        Thu, 23 May 2019 12:00:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558638036; cv=none;
        d=google.com; s=arc-20160816;
        b=Eknz2S7g/m4T+Q5qPUvovXdoMP8dnsdmbcqFVXimz6oPPtjLS2jEA60BcO10Dj103G
         +RpgHCJm9fgHSvBIihePrV0bxfLrpCzS71r4uws98YwxsdEOGyhERU34Kxzku9jvlqXx
         g42bEXQ82RZSp5kBVmWXDpogJWWAMMCv4vj0ZNRVYtEqphcwIedWJMKOZWWyT5YUDpfi
         G39lO8j8dCsiTH8pV3egNV0bm3O3bjmHZyWhx7Uct8CP0tjQFYXyMYR+dyHgA/WBy1gF
         21T86xmaPUqx43BPLBCAWWla/EG4Yy5bTmjFp6R8WGYiu80i6Buc+zfr/IyepxV3kXDL
         c+Vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2ANG0ElVZ/rPDPxKXuA88IUbN3whPdkvGrD4K4bBAhg=;
        b=G9S3vv0WoD+OZ8zrlotDoe072Pf5a6E6LMyLGZxl2/wPtxyo54q3CfDc4JSr3R/TBF
         2wVVvivT1Ncyqw9l5mJb5MFGaoMuSnqPRslgqKi/7nes2ygqCkHIaqJtUJoI32Nzkcbk
         ABnrJMxxwapjGJNeOm9d7pFrm4+LqaX42Dah6UqcqbGdV2QwYeA6UDGcHX4J+kiDEQN3
         SQWakHYlLFvHvCmzAonPe/o7XNsmKITM+aAOhxWB17D4bzshokxVoh6VZCf8Mu9x2pHH
         Si7gc50uP1w1q3CRYenegWke5aih5ujK9uN78aHvWeVVLhjqETpLZS44FXpC/L4pwpLQ
         /M3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UKb2x9rl;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t4si536185plb.11.2019.05.23.12.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 12:00:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UKb2x9rl;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CFE1021773;
	Thu, 23 May 2019 19:00:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558638036;
	bh=13UIe49+GBeGtJ+E53dBPhK+OZie9iCfaWakjVcwuYM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=UKb2x9rl1vfTGb8v0sVVNuU2To49zaCWbwzfJAwkWxeIzgiVpA7tzDS0Z/6Vr1Vp3
	 ndIElgQ3+ytxDzjPz2BeRmZWJmoBbIuOz2CVquV3kDamimSK+VAMKV4E7PML5ctTts
	 apps6YWhnSV9Sghzka5xpyBkV7eA3kTcQcYnpuOs=
Date: Thu, 23 May 2019 12:00:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Aaron Lu <aaron.lu@linux.alibaba.com>
Cc: linux-mm@kvack.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins
 <hughd@google.com>
Subject: Re: [PATCH] mm, swap: use rbtree for swap_extent
Message-Id: <20190523120035.efb7c3bf4c91e3aef255621c@linux-foundation.org>
In-Reply-To: <20190523142404.GA181@aaronlu>
References: <20190523142404.GA181@aaronlu>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 May 2019 22:24:15 +0800 Aaron Lu <aaron.lu@linux.alibaba.com> wrote:

> From: Aaron Lu <ziqian.lzq@antfin.com>
> 
> swap_extent is used to map swap page offset to backing device's block
> offset. For a continuous block range, one swap_extent is used and all
> these swap_extents are managed in a linked list.
> 
> These swap_extents are used by map_swap_entry() during swap's read and
> write path. To find out the backing device's block offset for a page
> offset, the swap_extent list will be traversed linearly, with
> curr_swap_extent being used as a cache to speed up the search.
> 
> This works well as long as swap_extents are not huge or when the number
> of processes that access swap device are few, but when the swap device
> has many extents and there are a number of processes accessing the swap
> device concurrently, it can be a problem. On one of our servers, the
> disk's remaining size is tight:
> $df -h
> Filesystem      Size  Used Avail Use% Mounted on
> ... ...
> /dev/nvme0n1p1  1.8T  1.3T  504G  72% /home/t4
> 
> When creating a 80G swapfile there, there are as many as 84656 swap
> extents. The end result is, kernel spends abou 30% time in map_swap_entry()
> and swap throughput is only 70MB/s. As a comparison, when I used smaller
> sized swapfile, like 4G whose swap_extent dropped to 2000, swap throughput
> is back to 400-500MB/s and map_swap_entry() is about 3%.
> 
> One downside of using rbtree for swap_extent is, 'struct rbtree' takes
> 24 bytes while 'struct list_head' takes 16 bytes, that's 8 bytes more
> for each swap_extent. For a swapfile that has 80k swap_extents, that
> means 625KiB more memory consumed.
> 
> Test:
> 
> Since it's not possible to reboot that server, I can not test this patch
> diretly there. Instead, I tested it on another server with NVMe disk.
> 
> I created a 20G swapfile on an NVMe backed XFS fs. By default, the
> filesystem is quite clean and the created swapfile has only 2 extents.
> Testing vanilla and this patch shows no obvious performance difference
> when swapfile is not fragmented.
> 
> To see the patch's effects, I used some tweaks to manually fragment the
> swapfile by breaking the extent at 1M boundary. This made the swapfile
> have 20K extents.
> 
> nr_task=4
> kernel   swapout(KB/s) map_swap_entry(perf)  swapin(KB/s) map_swap_entry(perf)
> vanilla  165191           90.77%             171798         90.21%
> patched  858993 +420%      2.16%      	     715827 +317%    0.77%
> 
> nr_task=8
> kernel   swapout(KB/s) map_swap_entry(perf)  swapin(KB/s) map_swap_entry(perf)
> vanilla  306783           92.19%             318145	    87.76%
> patched  954437 +211%      2.35%            1073741 +237%    1.57%
> 
> swapout: the throughput of swap out, in KB/s, higher is better
> 1st map_swap_entry: cpu cycles percent sampled by perf
> swapin: the throughput of swap in, in KB/s, higher is better.
> 2nd map_swap_entry: cpu cycles percent sampled by perf
> 
> nr_task=1 doesn't show any difference, this is due to the
> curr_swap_extent can be effectively used to cache the correct swap
> extent for single task workload.

Seems sensible and the code looks straightforward.  Hopefully Hugh will
be able to cast a gimlet eye over it.

>  
> ...
>
> +static struct swap_extent *
> +offset_to_swap_extent(struct swap_info_struct *sis, unsigned long offset)
> +{
> +	struct swap_extent *se;
> +	struct rb_node *rb;
> +
> +	rb = sis->swap_extent_root.rb_node;
> +	while (rb) {
> +		se = rb_entry(rb, struct swap_extent, rb_node);
> +		if (offset < se->start_page)
> +			rb = rb->rb_left;
> +		else if (offset >= se->start_page + se->nr_pages)
> +			rb = rb->rb_right;
> +		else
> +			return se;
> +	}
> +	/* It *must* be present */
> +	BUG_ON(1);

I'm surprised this doesn't generate a warning about the function
failing to return a value.  I guess the compiler figured out that
BUG_ON(non-zero-constant) is equivalent to BUG(), which is noreturn.

Let's do this?

--- a/mm/swapfile.c~mm-swap-use-rbtree-for-swap_extent-fix
+++ a/mm/swapfile.c
@@ -218,7 +218,7 @@ offset_to_swap_extent(struct swap_info_s
 			return se;
 	}
 	/* It *must* be present */
-	BUG_ON(1);
+	BUG();
 }
 


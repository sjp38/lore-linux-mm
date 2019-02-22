Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94840C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 13:01:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47392207E0
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 13:01:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="CCBhO0De"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47392207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4CB88E0106; Fri, 22 Feb 2019 08:01:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFC8B8E0105; Fri, 22 Feb 2019 08:01:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9FDF8E0106; Fri, 22 Feb 2019 08:01:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7404A8E0105
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 08:01:32 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o24so1676688pgh.5
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 05:01:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=onkZE8WbSVFAq66ZVCGJ/2/k18VmMeh7kNAg+mwLHWw=;
        b=SLJNyi08SKal+kE6WTc9qAPmS1TDXj75BySK5TFopWAsYnTuKp7GhWN6Agr6Os2TOr
         MjN2/8oP82tQDtSWG99RKe7X5kpXyIFhBV07MIJ4Xi/A03c9Yo+LHyh+qz+mLKuWvhqQ
         SM1IH/3CbZQxAsju1u/0NhCx+XOjIJELsJKaf8G5Geu7lJmMD1+W9mS/o8PFLGZlr0KL
         a92Jsp+SOWQr7pYhQvTI00B6SLGNxNUC7/sFF8p8R0cwj5N5zg28kP8DkgAs7SgiJDu1
         ijM0I1xM86W+8D+po7n/NjMtVen+/PB7bF8wV7v074vvxkLTDMlF7R5Kw+hBFyFmKWqM
         TCEQ==
X-Gm-Message-State: AHQUAuYyM90jHUVxsKD0bwVD2DhPemh/sk8Opc5HR6j7be7plCN9pmZT
	k+Ax/74fUu2wGGpHqhjZyqw6pABec8pdPiEReUZb4tc/LXeYWCKQasQiwPFUzC/i3dfDMv7jxeY
	Lu6fCQ+vvG96eVQUi934VJr5E0y9O0MEhw2035XPW1jGFGaV0NO0ZaDIQE20U1xjl77U+WKHwzW
	uy7KB5mppZzk08rl0OKm4Y9E8Rif/rmI05Duq+21w9nuayxLqh5zFbRhWH0YaoZPD5HztPdl+5L
	kAo3bjUYTFhIKaaIEg44KoguhEN8I5rZjjNXnhjmiyzYlZka0QIVIcwOYv8VfrlTLtDawU66ZCO
	bOvqQDbqxnF6Erg5VsGs4zYMffa5BLsTEzwEAiBj35LP7apMHdJ42IEBYYRM1CGWUzvUE82ymx4
	Y
X-Received: by 2002:a63:235c:: with SMTP id u28mr3941332pgm.400.1550840492062;
        Fri, 22 Feb 2019 05:01:32 -0800 (PST)
X-Received: by 2002:a63:235c:: with SMTP id u28mr3941240pgm.400.1550840490931;
        Fri, 22 Feb 2019 05:01:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840490; cv=none;
        d=google.com; s=arc-20160816;
        b=T7mH6sj/In828Cuao9ZIG7nNVOgBJdvRY9hB1LCcgp732QxrgodbRwmARyHZDd0WXC
         jxYC92WKr+OT+Wzqv2AhlxdCNXSaFi/w5LoTXJUXBWtzDVZxqjHrVgmU4V/JCNjUUOmd
         MHzCDI5TT+eRLwxz1PCG3rxkp+IJ8db1GuoS+byt0B0qEE5cJpuUbtuq8DEgUzjh0zkt
         qxtzdlG10HHDZyuOQa6+AFgPk728SYKRLpt2ix60q55srmqtp6fLdz32/gQsWMOks/Mk
         vuDfGzxY01rhZr6d8YjbUVH+9ovrC19mNH9sJwaqym7smScYpTJlW0uqBfeCfV90Y0do
         dU5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=onkZE8WbSVFAq66ZVCGJ/2/k18VmMeh7kNAg+mwLHWw=;
        b=mp43WF6d4qeIfmsffALS0cS3lMiwwKwyc7NcncFupl/ehU6pog0DLF3juD8d53ppb9
         tQ4irGt6IO8sDfv2hH6jvtbHqEkTCX+q9+1lAdjpm7VfEv+moKCwB6pq3QMnjOMRPzUD
         L1xlFvCJ/CwV+4VHvitQlIbfTtLsViAYYEYRUhwDllx9fRjjqEz2hwv7Jw9+fsUv+/sp
         1E9HvG9zfHd+ebYC+hZKyOCMoLeAPMNgnvAPNX5zMnS1cKO2O7KX+D6+BYE3+IDDcGhW
         TZlVDtws6oa0RKQzTdGVY3l3Sxsf6M+ApCRSM8cWHoRWLsQ0JSbPPbwyrRCbWNflD14r
         m+eQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=CCBhO0De;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p186sor2242930pfp.17.2019.02.22.05.01.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 05:01:30 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=CCBhO0De;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=onkZE8WbSVFAq66ZVCGJ/2/k18VmMeh7kNAg+mwLHWw=;
        b=CCBhO0DeHvPnX4smOVqBA3ma1CsqYKz79vk36KDNQvAiU9IE4jYxbC9bYdXbxq2XZl
         8DKg39/L2uT2RaXxhiHQ62V8we8DpABwhQpPpzM3+biaCQjizItVJ6qtxICY031D5XXJ
         ntaNHbnLWU5N1WTLTvKHA3l+vDW1WKW5ehxEAdxgyy3MBntk1RUDkhuU5Zj8lKNFdF8h
         1nUWYHyGdYee2NoT4ZebPXaMUvPzfcLlX4sdgXByTx92SZ0PC6uvzmwRoik53i/yYUan
         q5PbPElWBwlfVYARUlujnHmds2/kbVPimQk/qAxOdRyojDPqFojOzpb5+pUN9iJVumSv
         b+hQ==
X-Google-Smtp-Source: AHgI3Ibj7qZvvdq1/wt4KP+58XgtGJ+zPbnw0GY+h8/WF7m62jomELxnWg3mhD4zKB6qLPOHVv56UA==
X-Received: by 2002:aa7:8847:: with SMTP id k7mr4034679pfo.99.1550840490132;
        Fri, 22 Feb 2019 05:01:30 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.44])
        by smtp.gmail.com with ESMTPSA id u186sm2360688pfu.51.2019.02.22.05.01.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 05:01:29 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id B38F2301708; Fri, 22 Feb 2019 16:01:25 +0300 (+03)
Date: Fri, 22 Feb 2019 16:01:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org, hughd@google.com, vbabka@suse.cz,
	joel@joelfernandes.org, jglisse@redhat.com,
	yang.shi@linux.alibaba.com, mgorman@techsingularity.net
Subject: Re: [RFC PATCH] mm,mremap: Bail out earlier in mremap_to under map
 pressure
Message-ID: <20190222130125.apa2ysnahgfuj2vx@kshutemo-mobl1>
References: <20190221085406.10852-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221085406.10852-1-osalvador@suse.de>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 09:54:06AM +0100, Oscar Salvador wrote:
> When using mremap() syscall in addition to MREMAP_FIXED flag,
> mremap() calls mremap_to() which does the following:
> 
> 1) unmaps the destination region where we are going to move the map
> 2) If the new region is going to be smaller, we unmap the last part
>    of the old region
> 
> Then, we will eventually call move_vma() to do the actual move.
> 
> move_vma() checks whether we are at least 4 maps below max_map_count
> before going further, otherwise it bails out with -ENOMEM.
> The problem is that we might have already unmapped the vma's in steps
> 1) and 2), so it is not possible for userspace to figure out the state
> of the vma's after it gets -ENOMEM, and it gets tricky for userspace
> to clean up properly on error path.
> 
> While it is true that we can return -ENOMEM for more reasons
> (e.g: see may_expand_vm() or move_page_tables()), I think that we can
> avoid this scenario in concret if we check early in mremap_to() if the
> operation has high chances to succeed map-wise.
> 
> Should not be that the case, we can bail out before we even try to unmap
> anything, so we make sure the vma's are left untouched in case we are likely
> to be short of maps.
> 
> The thumb-rule now is to rely on the worst-scenario case we can have.
> That is when both vma's (old region and new region) are going to be split
> in 3, so we get two more maps to the ones we already hold (one per each).
> If current map count + 2 maps still leads us to 4 maps below the threshold,
> we are going to pass the check in move_vma().
> 
> Of course, this is not free, as it might generate false positives when it is
> true that we are tight map-wise, but the unmap operation can release several
> vma's leading us to a good state.
> 
> Because of that I am sending this as a RFC.
> Another approach was also investigated [1], but it may be too much hassle
> for what it brings.

I believe we don't need the check in move_vma() with this patch. Or do we?

> 
> [1] https://lore.kernel.org/lkml/20190219155320.tkfkwvqk53tfdojt@d104.suse.de/
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/mremap.c | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 3320616ed93f..e3edef6b7a12 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -516,6 +516,23 @@ static unsigned long mremap_to(unsigned long addr, unsigned long old_len,
>  	if (addr + old_len > new_addr && new_addr + new_len > addr)
>  		goto out;
>  
> +	/*
> +	 * move_vma() need us to stay 4 maps below the threshold, otherwise
> +	 * it will bail out at the very beginning.
> +	 * That is a problem if we have already unmaped the regions here
> +	 * (new_addr, and old_addr), because userspace will not know the
> +	 * state of the vma's after it gets -ENOMEM.
> +	 * So, to avoid such scenario we can pre-compute if the whole
> +	 * operation has high chances to success map-wise.
> +	 * Worst-scenario case is when both vma's (new_addr and old_addr) get
> +	 * split in 3 before unmaping it.
> +	 * That means 2 more maps (1 for each) to the ones we already hold.
> +	 * Check whether current map count plus 2 still leads us to 4 maps below
> +	 * the threshold, otherwise return -ENOMEM here to be more safe.
> +	 */
> +	if ((mm->map_count + 2) >= sysctl_max_map_count - 3)

Nit: redundant parentheses around 'mm->map_count + 2'.

> +		return -ENOMEM;
> +
>  	ret = do_munmap(mm, new_addr, new_len, uf_unmap_early);
>  	if (ret)
>  		goto out;
> -- 
> 2.13.7
> 

-- 
 Kirill A. Shutemov


Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9775BC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:25:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4001E21019
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:25:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda-com.20150623.gappssmtp.com header.i=@toxicpanda-com.20150623.gappssmtp.com header.b="dY7JY2Oq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4001E21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAB528E0004; Wed, 13 Mar 2019 10:25:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5B668E0001; Wed, 13 Mar 2019 10:25:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 924068E0004; Wed, 13 Mar 2019 10:25:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B96B8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 10:25:31 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d8so1658516qkk.17
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 07:25:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fHRa1BKeIVaZZZGPwbJkmSmgRFotNmkW7TMj1bw0ncA=;
        b=os9y4QNmeGYSIzKsGM92Ui2B1jpX+rvGjdhaBGvshC+l65DwPFqoajvPZkTIwg5HFy
         g+MBHU3NYKjchGILs54Yn7Y2cvvKhucp1tDsj6QcxVm92C8yUMS/diUD7glGqI0AiCIY
         vEZnjxFXtdNaouYRnBOP5Vu8y3Ei+YxGycMdUm+W5L/Vx8+nR/eZ+wj4zl0n7AFYQ8QC
         tub8/GSrcGP+X6g7DNPInOQ59033R/i5IpvQBcOZTlYq2dtWjRiihrb5wOhAOdB37P2m
         bG27KRUuRLCtVIgbs2nXl/NRzLU8HaCQhBP+hOwST5mtbJJIMGPsF5Vrz9zmjRqzPgul
         aF9Q==
X-Gm-Message-State: APjAAAXivRg3f/k5WS9D2VvSNd4QD9gsDtH1Mbb14xXEB705kkDuK/wK
	1e6KBb6gCcrSN3z94C3ng9UddDTyzWGtFtE40DCZQO39tq/UiaT5Jiz4uNWysF924GA9or9xLaW
	YuNBvvsOO4EmW/uwNRkmhL48yonETN4XcxbspFHnWGyqOMwIMLtTnSPlUswOp86MCjsfVIEbuiq
	Qw22K5d7HML8AkEQ2ppzkaK+AJnYxHlty++tVYvLhv2F5dcfGX8saujqHK3vSjmlP3m9NFAwlGT
	B4FSCVwmmMZi0aGRe6GQm/KZvaXMyQzNEM2UdtgZgditO8rcihz3ShL477cWwaMkaODBTHF4nyv
	wqLnNWXt+LXA7VSKWwpl5TxYBES7wNFSwyAUwTHyfjxmVhaxhXuAApn6GWqVf3Tmqf8IQMv/Fmr
	P
X-Received: by 2002:ac8:3445:: with SMTP id v5mr6457339qtb.368.1552487131008;
        Wed, 13 Mar 2019 07:25:31 -0700 (PDT)
X-Received: by 2002:ac8:3445:: with SMTP id v5mr6457299qtb.368.1552487130246;
        Wed, 13 Mar 2019 07:25:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552487130; cv=none;
        d=google.com; s=arc-20160816;
        b=xNmsOS25WKpoErujnIVcXmF+FRKClcs5z7H72aIMZPyeejZNhWMByieRCHMyrlUuSQ
         thfi4wcNARPBuvpA9mkvjPLGyD0eRZYoph20kGHrKNhh0a4U6LdukqH68LbqnKkPdVxs
         nlpryG4g8A9DMXldEZZHUz3wjBBvAgJj1AkH5cufqeu/FX0d0kHuPqdFYfBA1JvysP1F
         lwksTlVbuJlK0NuDg6+77jU+zmwcTxkz7BldVO7XXY51llIzmh/VXdH4jw3a6WDV0VHP
         r9RxksI0/9eken/uoNkDtIQhUuHkFNTKIAdzHs4X0ktDQkejHUFoeETMyUSYuS1cWAu7
         v72g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fHRa1BKeIVaZZZGPwbJkmSmgRFotNmkW7TMj1bw0ncA=;
        b=VMnLsD6gfjkn9cQ+xpT65ygMkYIOzLeZ91TbskJwf+3t7+qoVHLphYyQzicxxXmss4
         d33pLyZAEKdN760V396b2Mulxm/S9EH5XwspXE5Ko+4KTfTE6PvHivSSTjwVzT6/XEnj
         fgYa4xz+BM3tcO6dwp+Q4hUCM1Bx0t4AanAQuqchblESXE1kHinJXdw54OQEUCOI7J+a
         bOL7ooCnryzRYubIz6MoOYsebkyH/5yAYVxEySkaOLzLhB81q0E4fIi90zOgf0EjrD3e
         eJsEzyxRCsvipOiBl0lbeUszWDZRSHaw/vb6ndikGxBwqZ56wNOcNwlnZHRV746mNfeF
         A9Fg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=dY7JY2Oq;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s32sor14419365qta.71.2019.03.13.07.25.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 07:25:30 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=dY7JY2Oq;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fHRa1BKeIVaZZZGPwbJkmSmgRFotNmkW7TMj1bw0ncA=;
        b=dY7JY2OqUsl6w+atsM0dHifofqzVuzyBGTuoy/iobCTR9obiXC65yncXVlT6QbWC3e
         ri2GAphaax+ctDxeJljMo8DceyC25qLgUmD+8RpqjRgv9utjAc1+wp/0c69ctb+z/CK4
         YRPvDaHPqJFPElRoyaWwKY0hgwaACjsrUQ1LrJyp6Ws+PbZIXjFr3eEpKLHwJH2eO7gf
         EOB8nBuC9kKEKCKxXIdMsylDwh0540bbHeUeCfjoTn6WOu37JwX/oP/CDBwbTpfgShiO
         cLrYuRCdUBhy26V0SPtm2xI2NiQYYHfou4QB/BbcqgBQEQcsIJc5ZCTlSB18GkdBArjW
         9AHQ==
X-Google-Smtp-Source: APXvYqwwkKDuZXGKZee8n30lVujlE+eeVGXgvlsjC5DpSXsKyD4zDROaZcZK8Ub7G4fMim4CdwKwdA==
X-Received: by 2002:aed:23ae:: with SMTP id j43mr34170070qtc.318.1552487129633;
        Wed, 13 Mar 2019 07:25:29 -0700 (PDT)
Received: from localhost ([107.15.81.208])
        by smtp.gmail.com with ESMTPSA id x17sm7362929qka.94.2019.03.13.07.25.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 07:25:28 -0700 (PDT)
Date: Wed, 13 Mar 2019 10:25:27 -0400
From: Josef Bacik <josef@toxicpanda.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Josef Bacik <josef@toxicpanda.com>, linux-mm@kvack.org,
	kernel-team@fb.com
Subject: Re: [PATCH] filemap: don't unlock null page in FGP_FOR_MMAP case
Message-ID: <20190313142526.zafldmokz3ggywv6@MacBook-Pro-91.local>
References: <20190312201742.22935-1-josef@toxicpanda.com>
 <20190312140623.54e337e01eb9fbfe11258330@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312140623.54e337e01eb9fbfe11258330@linux-foundation.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 02:06:23PM -0700, Andrew Morton wrote:
> On Tue, 12 Mar 2019 16:17:42 -0400 Josef Bacik <josef@toxicpanda.com> wrote:
> 
> > We noticed a panic happening in production with the filemap fault pages
> > because we were unlocking a NULL page.  If add_to_page_cache() fails
> > then we'll have a NULL page, so fix this check to only unlock if we
> > have a valid page.
> > 
> > Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> > ---
> >  mm/filemap.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index cace3eb8069f..2815cb79a246 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -1663,7 +1663,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
> >  		 * add_to_page_cache_lru locks the page, and for mmap we expect
> >  		 * an unlocked page.
> >  		 */
> > -		if (fgp_flags & FGP_FOR_MMAP)
> > +		if (page && (fgp_flags & FGP_FOR_MMAP))
> >  			unlock_page(page);
> >  	}
> >  
> 
> Fixes "filemap: kill page_cache_read usage in filemap_fault".
> 
> This patch series:
> 
> filemap-kill-page_cache_read-usage-in-filemap_fault.patch
> filemap-kill-page_cache_read-usage-in-filemap_fault-fix.patch
> filemap-kill-page_cache_read-usage-in-filemap_fault-fix-2.patch
> filemap-pass-vm_fault-to-the-mmap-ra-helpers.patch
> filemap-drop-the-mmap_sem-for-all-blocking-operations.patch
> filemap-drop-the-mmap_sem-for-all-blocking-operations-v6.patch
> filemap-drop-the-mmap_sem-for-all-blocking-operations-fix.patch
> filemap-drop-the-mmap_sem-for-all-blocking-operations-checkpatch-fixes.patch
> 
> has been stuck since December.  I have a note here that syzbot reported
> a use-after-free.  What's the situation with that?
> 

Yup that was fixed by

filemap-drop-the-mmap_sem-for-all-blocking-operations-fix.patch

so we're good there.

> I also have a cryptic note that
> filemap-drop-the-mmap_sem-for-all-blocking-operations-v6.patch is
> "still fishy".  I'm not sure what I meant by the latter - the (small
> amount of) review seems to be OK.  Do you recall what issues there
> might have been and the status of those?

Looking back at the discussion I _think_ the "still fishy" thing was you were
concerned that now if we can't get a page in do_async_mmap_readahead and we
dropped the mmap sem we'd return VM_FAULT_RETRY instead of -ENOMEM.  Jan pointed
out that we have to do this as we've dropped the mmap_sem and it's the only safe
thing to return so we're ok there.  If that's not it then I'm not sure why you
were still concerned with it.

For what its worth these patches have been in production since December, we only
noticed this panic on a small set of hosts that still have ext4 so by-in-large
they've been stable.  Thanks,

Josef


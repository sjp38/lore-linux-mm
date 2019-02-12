Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE0FFC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:49:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A78A221773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:49:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bYzagzji"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A78A221773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40A3D8E0002; Tue, 12 Feb 2019 10:49:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 392AC8E0001; Tue, 12 Feb 2019 10:49:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25C9F8E0002; Tue, 12 Feb 2019 10:49:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D2D7F8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:49:03 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 71so2474407plf.19
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:49:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=rqgxVa0cdRH1Jb2ZEJnRnt7ftvK8nafkOmZw+k+9UrA=;
        b=OEy9fwrf36cnGUyUVHyxJ8q9jxprPUI+uhBE0AffbS0kX5IeXG+KOx+WXSTQ/H78kg
         6bisFKeoTEYQLew3l7Vyn8zXbvOBNK6pQn+9yKGOo+jHYyVGn6v2LEB1SviKXHKp9vcO
         KBsHzByvKX6FHzUUyua85HvTF5+BaDYQIfXhBRERdIQ7SeE+1HE3HdWYBT5yOmG3BP6o
         peCqhBVi43sbEKuYH/tXz6HwZLjOv4WTZKTUQqSSB/Kt1ffVd51TWL3gDsyd6ulyUP7C
         KPq4K3TqZ4mfuW5nHf7LC9Bvp8qLB0xlhO7j3LwxncDyCMzbx8QQ5o4ErA4tT9ss+U7W
         Z+zg==
X-Gm-Message-State: AHQUAubclBSUSa20hiUCzdC9LomSbSYPc4PUf6MAbnEmM37MYKLQYVrx
	N2u9tqO6WpVutjx/OCdeV7A2B7ETnNtgZExeDrPeJYnNYyqW0MmYvqVqxkgNjUZVl70ROEPZPg+
	lD0rhB+B4jYys7xBuOlikhVOETGAfhtqhdP+TV1ZfkpFRBrXzJfDTKSPFFg+K7Fcgvg==
X-Received: by 2002:a17:902:70c9:: with SMTP id l9mr4678309plt.308.1549986543527;
        Tue, 12 Feb 2019 07:49:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbTlVcoQJeeIZTboxMNfrHYLFyPDgTh5QLjK9dtjvUKaH/ps9CKRyYo4zEzqKsZl3wxO1d6
X-Received: by 2002:a17:902:70c9:: with SMTP id l9mr4678256plt.308.1549986542685;
        Tue, 12 Feb 2019 07:49:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549986542; cv=none;
        d=google.com; s=arc-20160816;
        b=0RpV6usQuxzTXDGwpsOqwiUspz8caK1b8e2wF7xoyywWA29WJBkSpk+plRnmxbyJf3
         kWOtiIRjPjOq5CiQFjkpnWH+CkE1xDhqfbmcF34nYQxbPT6ITSN2fMLdEbtN4KtMrpph
         W3RtCBAyWcH7aCPcwiVDwu3z7KN0EFEgZuOhtVGntrnL3QLTjLgfSugSRPNgfmW1qQaL
         fp6WInCeZvU1hZQVJ+plus1J6t5E4SM2fNLxsvSae/nysrvfbHcv9rVZ6dVezfSIwSW5
         U3SsLW5TRnLe32EyFzeYaqA/euXSkRhmXQoSTl3WUEuereyPuuUhkoFnb+gf6kBZl427
         Gqaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=rqgxVa0cdRH1Jb2ZEJnRnt7ftvK8nafkOmZw+k+9UrA=;
        b=JuMxCPvxM1E0G7edhJjkFljRBfiAR504yEc6TedP5XRS59Ax2iZulgLoWzuQVW95Y8
         qWNstfgSM2h1czaOKWjJcBy6uJzAfUnO7vTEJkFXZSo0cRcEWhcCAvWS3mFb7MWBM/36
         75L6NtNeuM/QzKYpGtEIAVgkLzJyghHzKl2tCBaKg1o63U3DLf09kgXAxPYM+slPCE7K
         Tw5Tn4i2KBxDGo7hc4tWyIZvkrkYf8QXezHkSQEkXDgnON2o6oijow7rvQytQ9G1Qku1
         60fpoBVv+JXWhBpl603Oj2Ju2KUWkvENwzVdA8chEOkoHetMJyQx4b2y1GU7tqp4cSa5
         rl7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bYzagzji;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d10si13330998plo.286.2019.02.12.07.49.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:49:02 -0800 (PST)
Received-SPF: pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bYzagzji;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from pobox.suse.cz (prg-ext-pat.suse.com [213.151.95.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CF8F320842;
	Tue, 12 Feb 2019 15:48:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549986542;
	bh=K0aoyY/nb/VrHdL1zAx8Hnxt0yP94fhovRVQnknUtQU=;
	h=Date:From:To:cc:Subject:In-Reply-To:References:From;
	b=bYzagzjirKHE5hOPkjMM1eAPxn0VUwCCwpIpcySxA/iVtphDZycLfaiJEJSdQtaaQ
	 7xynE/cz1bfB1cEKyrodMbE0ALVjPwLCkdcotWgLGz8o63sTGTDQxwJAnJB01EJ4cF
	 i2/BMJJeb3l4zLoqEtpuQz/MhfCmw6tbsyZDQ78g=
Date: Tue, 12 Feb 2019 16:48:56 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Dave Chinner <david@fromorbit.com>
cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, 
    Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
    Dominique Martinet <asmadeus@codewreck.org>, 
    Andy Lutomirski <luto@amacapital.net>, Kevin Easton <kevin@guarana.org>, 
    Matthew Wilcox <willy@infradead.org>, Cyril Hrubis <chrubis@suse.cz>, 
    Tejun Heo <tj@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, 
    Daniel Gruss <daniel@gruss.cc>, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT
 is set for the I/O
In-Reply-To: <20190201014446.GU6173@dastard>
Message-ID: <nycvar.YFH.7.76.1902121645470.11598@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-3-vbabka@suse.cz> <20190131095644.GR18811@dhcp22.suse.cz> <20190201014446.GU6173@dastard>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2019, Dave Chinner wrote:

> So, I'll invite the incoherent, incandescent O_DIRECT rage flames of
> Linus to be unleashed again and point out the /other reference/ to
> IOCB_NOWAIT in mm/filemap.c. That is, in generic_file_read_iter(),
> in the *generic O_DIRECT read path*:
> 
> 	if (iocb->ki_flags & IOCB_DIRECT) {
> .....
> 		if (iocb->ki_flags & IOCB_NOWAIT) {
> 			if (filemap_range_has_page(mapping, iocb->ki_pos,
> 						   iocb->ki_pos + count - 1))
> 				return -EAGAIN;
> 		} else {
> .....

OK, thanks Dave, this is a good point I've missed in this mail before 
(probabably as I focused only on the aspect of disagreement what NONBLOCK 
actually means :) ). I will look into fixing it for next iteration.

> It's effectively useless as a workaround because you can avoid the
> readahead IO being issued relatively easily:
> 
> void page_cache_sync_readahead(struct address_space *mapping,
>                                struct file_ra_state *ra, struct file *filp,
>                                pgoff_t offset, unsigned long req_size)
> {
>         /* no read-ahead */
>         if (!ra->ra_pages)
>                 return;
> 
>         if (blk_cgroup_congested())
>                 return;
> ....
> 
> IOWs, we just have to issue enough IO to congest the block device (or,
> even easier, a rate-limited cgroup), and we can still use RWF_NOWAIT
> to probe the page cache. Or if we can convince ra->ra_pages to be
> zero (e.g. it's on bdi device with no readahead configured because
> it's real fast) then it doesn't work there, either.

It's though questionable whether the noise level here wouldn't be too high 
already for any sidechannel to work reliably. So I'd suggest to operate 
under the assumption that it would be too noisy, unless anyone is able to 
prove otherwise.

Thanks,

-- 
Jiri Kosina
SUSE Labs


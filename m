Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CEABC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:54:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FB222173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:54:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FB222173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFE088E0005; Tue, 26 Feb 2019 02:54:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B85448E0002; Tue, 26 Feb 2019 02:54:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4C968E0005; Tue, 26 Feb 2019 02:54:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 760678E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:54:58 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 35so11634494qtq.5
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 23:54:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=o5DctiRpCNLxl+C4Hk/vdR8qoOFlhqWm2wcjTTD9Glg=;
        b=p6q039rHFLkehBfJtvKhHXEOl7UKrnsFXAaE10AusVHvCtFsvZ7U9ddJOOHqcVWB6S
         qLQujU4DaN0/gbARPDGsqdy0yOH1/6wFReNKl4oIQkNduhCzf2lFa/CQRpxAMDBvSmPa
         TDeLk6x52YQgR6qURY0gjrFZ4bKGMfEMY+g7AXBTvmmJ/W92xpE2m8gqecjkRmCE4pT2
         NlHBI3xV/4pKGcLy08rh//Oks/heRqAbBfm1I/n9zWSziMuPEPm1xcEOpc1Wg14cOh9Q
         VWI+B8TZLbd8iz0N1yvxjILgcH33snmFfEvnUAVjpUIzjU2bRrswZUCHj0LI0NkvvuRE
         q2Yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub6dmwaYZOGGDsQwKizTYoMYsedJ7/QuZocDXC2ZDcav3W2oyct
	gk/uny9gQ/nobYES7Cr15y0ASOoNvwZ3ve6Xv6TKU062Idb6syJ5WSzgiVIQN+jFAPUEgEH9qiA
	bamt3miMrXe/vzLN3Vzkng9AtQQNA5gLSEBjS0rg/egWm2HZDV8tfC5Of+cZWw+R6MA==
X-Received: by 2002:a0c:d1a7:: with SMTP id e36mr17261975qvh.127.1551167698242;
        Mon, 25 Feb 2019 23:54:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZRzona8Ye9F08Vt4odXWbYymNi0AWZFS7oACFQJmtPVxtzhGFNOSqeg5acvmOSkmjFtku0
X-Received: by 2002:a0c:d1a7:: with SMTP id e36mr17261955qvh.127.1551167697609;
        Mon, 25 Feb 2019 23:54:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551167697; cv=none;
        d=google.com; s=arc-20160816;
        b=HruAma357jLuyZFrAcLDSl9y9M3E/ds3of7nbfeT3Zd+jBffe7/xoOJxCkPsxgV0/b
         GCtCJPIMuhq+2Igd6anfgWXKLVrTxZYG4Re3rPSIwcvTGQfS+VA2PAbfXldxGjEZxCX+
         QI8iPj+ucgQZR63sE3ubdbcueBk05pivKE1s+wUGJ0V8Xd/iU7Azxl3FjpRBdT52qUTG
         /cYzv905GrT96H6BhoaWvexjztjA4RTGmG3wSrRBmDRC8BuiFwz3ADNsAFbi6ifUero8
         EnwJznALxujCa8H+4NuNmYM1j5J4gLiY4wNOKPxAfMOYcc+OIXzrpi9PLar4rGTGDp0m
         /ZPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=o5DctiRpCNLxl+C4Hk/vdR8qoOFlhqWm2wcjTTD9Glg=;
        b=G+uDNyJslcRasda869ultlLKlCScNwsFBy/oCRHvPV56GSuQ9BuCWjoA+K2MCQIKnu
         PBqH1WKbG0wDE1BKqPLCLSm5kemGbrLJDKRR11BVAY7+DlKi1IVSv3cNQvtOFDGXXpRI
         wpmYzhOOqGHgj1jgtzS1Gn/eDA0A1S/htlaMQR8a1ar071lrzrxq3+lsVb3+tH1rihWo
         Pole+lxALVfk+dv7QViFUvoIQjKzHWVae420SIgOatjT7df3f9jRSLFbqCtvlzuqd4YS
         pVUYD/FI5l8bMzlYe8FwpWeEYZehvsbWuriay8LdHoM5HFPj3WuXkOufi0qHv/N6WJ84
         CQlA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w18si3080625qka.41.2019.02.25.23.54.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 23:54:57 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ABD7D3082B21;
	Tue, 26 Feb 2019 07:54:56 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7D2A21001DE2;
	Tue, 26 Feb 2019 07:54:46 +0000 (UTC)
Date: Tue, 26 Feb 2019 15:54:44 +0800
From: Peter Xu <peterx@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH v2 20/26] userfaultfd: wp: support write protection for
 userfault vma range
Message-ID: <20190226075444.GO13653@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-21-peterx@redhat.com>
 <20190225205233.GC10454@rapoport-lnx>
 <20190226060627.GG13653@xz-x1>
 <20190226064347.GB5873@rapoport-lnx>
 <20190226072027.GK13653@xz-x1>
 <20190226074612.GG5873@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190226074612.GG5873@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 26 Feb 2019 07:54:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 09:46:12AM +0200, Mike Rapoport wrote:

[...]

> > > > > > +int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
> > > > > > +			unsigned long len, bool enable_wp, bool *mmap_changing)
> > > > > > +{
> > > > > > +	struct vm_area_struct *dst_vma;
> > > > > > +	pgprot_t newprot;
> > > > > > +	int err;
> > > > > > +
> > > > > > +	/*
> > > > > > +	 * Sanitize the command parameters:
> > > > > > +	 */
> > > > > > +	BUG_ON(start & ~PAGE_MASK);
> > > > > > +	BUG_ON(len & ~PAGE_MASK);
> > > > > > +
> > > > > > +	/* Does the address range wrap, or is the span zero-sized? */
> > > > > > +	BUG_ON(start + len <= start);
> > > > > 
> > > > > I'd replace these BUG_ON()s with
> > > > > 
> > > > > 	if (WARN_ON())
> > > > > 		 return -EINVAL;
> > > > 
> > > > I believe BUG_ON() is used because these parameters should have been
> > > > checked in userfaultfd_writeprotect() already by the common
> > > > validate_range() even before calling mwriteprotect_range().  So I'm
> > > > fine with the WARN_ON() approach but I'd slightly prefer to simply
> > > > keep the patch as is to keep Jerome's r-b if you won't disagree. :)
> > > 
> > > Right, userfaultfd_writeprotect() should check these parameters and if it
> > > didn't it was a bug indeed. But still, it's not severe enough to crash the
> > > kernel.
> > > 
> > > I hope Jerome wouldn't mind to keep his r-b with s/BUG_ON/WARN_ON ;-)
> > > 
> > > With this change you can also add 
> > > 
> > > Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> > 
> > Thanks!  Though before I change anything... please note that the
> > BUG_ON()s are really what we've done in existing MISSING code.  One
> > example is userfaultfd_copy() which did validate_range() first, then
> > in __mcopy_atomic() we've used BUG_ON()s.  They make sense to me
> > becauase userspace should never be able to trigger it.  And if we
> > really want to change the BUG_ON()s in this patch, IMHO we probably
> > want to change the other BUG_ON()s as well, then that can be a
> > standalone patch or patchset to address another issue...
> 
> Yeah, we have quite a lot of them, so doing the replacement in a separate
> patch makes perfect sense.
>  
> > (and if we really want to use WARN_ON, I would prefer WARN_ON_ONCE, or
> >  directly return the errors to avoid DOS).
> 
> Agree.
> 
> > I'll see how you'd prefer to see how I should move on with this patch.
> 
> Let's keep this patch as is and make the replacement on top of the WP
> series. Feel free to add r-b.

Great!  I'll do.  Thanks,

-- 
Peter Xu


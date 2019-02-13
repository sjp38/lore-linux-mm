Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 726F9C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:38:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A8F2217F5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:38:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A8F2217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C925B8E0002; Wed, 13 Feb 2019 08:38:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3F748E0001; Wed, 13 Feb 2019 08:38:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE1798E0002; Wed, 13 Feb 2019 08:38:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 525618E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:38:30 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f11so1029163edi.5
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:38:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bm5uUr8Ra+OZXp25pW1LELKlbIi3ZN7tO3+pGsi91IY=;
        b=sUw/c4446ybLM8FUIRpg4fn51zJNb2a08hMUSZX/SZMOQ1XOkig9x4jcDUwaqcgU8M
         o955axiC9zqus/PgqNd3rVvwM/Yx/gegSxolfzQMfPz1zZ21r2CiFIDT2AZSlZSBWKMO
         l5giIiRoBE6/wvV/TDQFB6CZsRIHVjv3gFfUXIZKEetdGChg9cuYKrfusEyq1gRtlC0+
         Rieh5pifnL7kW/Z6ud5B1sg81ILX7P0pwfomPse5FRSFWqXUP9vrbcJd09qlK4Cm2Mt5
         lBsbOEb9RbdQt8T5jV8l2d3IRoQ3LDcwo7qay+6IfGbWiguzSJIHroFq5op243j/Ky2q
         YIhg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZqByWY9iCeQZFgOaVX0fLnSSu/5wTF9SwybW9pMaLyds4pEvDw
	nFyIbohnwYfp35jlqPI1apo6xNEGyYiSRPa4cWIigZ8heikqhrBk5D3RnoQap9WQWPhpsulz3QE
	iEOWLJ0BInqFzqGHzNjyYbvApbuGh26iG1z9S4uLJVmyTQRVZ0G1ccil0Zreb4Ek=
X-Received: by 2002:a50:d58d:: with SMTP id v13mr422964edi.67.1550065109869;
        Wed, 13 Feb 2019 05:38:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib5lK1Fn1f5kUYUySm40n4glqJvlbS3kRyrPh7fSIbDNgpSarGWW+5qB19TvA7REDpDB5eQ
X-Received: by 2002:a50:d58d:: with SMTP id v13mr422920edi.67.1550065109130;
        Wed, 13 Feb 2019 05:38:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550065109; cv=none;
        d=google.com; s=arc-20160816;
        b=jO2dMYMOQg8HT7SEV+iKrq0qCKauMdUqrtYxsluF3BTDh75kaHhbc5q+lUf4VM88q+
         phcqobAXwv8cjjoes/v5owOGupjhWF7G6eY+hayw8F07yCa0ojYIHQEuWX06F21ap90t
         zF04fPNEylxYrIuk/pkKp6QzkAJHzuHBapVWT9bzTMhrWRn5C7k79Y7IhPeFMC16BRtH
         MvzICxPZ7JQKi0sZX54TUhVBVcJzCM88i+uMy7z7CP0VfxUseHKBll2p5bKY0WIz5H78
         u/aoO5bGixtJKM1fPTT8wa+6jOfNpan5xKBB5Dy/IQVKNcOgpSwvPzmjI4MXoYlmtMdB
         4nJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bm5uUr8Ra+OZXp25pW1LELKlbIi3ZN7tO3+pGsi91IY=;
        b=AuekddkO0yM1CqwxrZJ5LlNaF/0euzZb+LBQx3+PHpd3UyOEDCF9a4rQIGGgJODDeF
         7/aARLtec1DvRHtG7X5q41ECKuh5UtdEkrSKXvvmBYJaauipj/TJKLQ/KM45Va+VPf8T
         6p5siG8L9kl8C9+exDKDTmfOt96/7v3Sn59/lFEWT0vGDzZ8Tj1aB3ILayDgZn1hGDf0
         gGgh0D4I6LKgP57vqwyPybyqO1l2etGLHdBOllEjaleGC+oXoAp/UvXv1lwffeCwgvjW
         z2xMVX49YUmwrss5FprOx05TbdQ0KIsxR3dmTjiJVoBlKJ54vTsXlShQ1zPSm9du7h0v
         ZMXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gs21si7180310ejb.3.2019.02.13.05.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 05:38:29 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 98D90AEBC;
	Wed, 13 Feb 2019 13:38:28 +0000 (UTC)
Date: Wed, 13 Feb 2019 14:38:27 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	lsf-pc@lists.linux-foundation.org,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [LSF/MM TOPIC] Non standard size THP
Message-ID: <20190213133827.GN4525@dhcp22.suse.cz>
References: <dcb0b2cf-ba5c-e6ef-0b05-c6006227b6a9@arm.com>
 <20190212083331.dtch7xubjxlmz5tf@kshutemo-mobl1>
 <282f6d89-bcc2-2622-1205-7c43ba85c37e@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <282f6d89-bcc2-2622-1205-7c43ba85c37e@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-02-19 18:20:03, Anshuman Khandual wrote:
> On 02/12/2019 02:03 PM, Kirill A. Shutemov wrote:
> > Honestly, I'm very skeptical about the idea. It took a lot of time to
> > stabilize THP for singe page size, equal to PMD page table, but this looks
> > like a new can of worms. :P
> 
> I understand your concern here but HW providing some more TLB sizes beyond
> standard page table level (PMD/PUD/PGD) based huge pages can help achieve
> performance improvement when the buddy is already fragmented enough not to
> provide higher order pages. PUD THP file mapping is already supported for
> DAX and PUD THP anon mapping might be supported in near future (it is not
> much challenging other than allocating HPAGE_PUD_SIZE huge page at runtime
> will be much difficult). Around PMD sizes like HPAGE_CONT_PMD_SIZE or
> HPAGE_CONT_PTE_SIZE really have better chances as future non-PMD level anon
> mapping than a PUD size anon mapping support in THP.

I do not think our page allocator is really ready to provide >PMD huge
pages. So even if we deal with all the nasty things wrt locking and page
table handling the crux becomes the allocation side. The current
CMA/contig allocator is everything but useful for THP. It can barely
handle hugetlb cases which are mostly pre-allocate based.

Besides that is there any real world usecase driving this or it is
merely "this is possible so let's just do it"?
-- 
Michal Hocko
SUSE Labs


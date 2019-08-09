Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AFA9C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:52:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC770217F4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:52:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SNwo9M1M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC770217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3535F6B000A; Fri,  9 Aug 2019 05:52:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 303C96B000C; Fri,  9 Aug 2019 05:52:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CC226B000D; Fri,  9 Aug 2019 05:52:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA5A36B000A
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 05:52:48 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x10so1429494pfn.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 02:52:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=coff5jRP+4bBeGfReMXie4tO+oyayDQ9HMdvtmpclDQ=;
        b=eVk+Rz3I3ILv7B/tnsFFIUI7hqDrf8IXoz973m/kRuxw1yz9Rbq0d7moPoxxD3R8Z/
         uqdyDCEAbk2l7y2Nx0dGtRymoCk7PoLjxWvEpNrlbdsSDOl0eZ1hYoI+0OaH1nLrdN8o
         nPnElAPg6qD1WZWDtokDPOU5VxZLARPXbxkgzt0IRxqcluRkvtsIHP1J4iefxBzrDX9O
         uB3ItNKPr5gioN6pN2YV6tiaNNZuucRSIHnJZyERRHEPu7kDdZjSM3LV7Ivypcgy9o9u
         O5Cyh6NYEOcrcksvKjhPwT++fdw5nTnHjD2gsph0Pxf662oP1KI0Fvja3qg7dr0QnluC
         oC8Q==
X-Gm-Message-State: APjAAAWhzIvYA2POdmAUGRWP8/S5C3m7927ABNUYVEiUVwB7p8fWAnae
	7FLro1i+J+J64FGsIav1/0gdmwWFPJO7v//jmtnLzzl8MScrMmUClUsmc/pajuVBtO6VVWfnGg9
	mxwmJgGwV1PbpdpinYTNx3ueKUOavTbrEuvQiuJBXVl7yPBLAI3keJnx9PCsiWTO1LQ==
X-Received: by 2002:a17:902:ac85:: with SMTP id h5mr18381918plr.198.1565344368527;
        Fri, 09 Aug 2019 02:52:48 -0700 (PDT)
X-Received: by 2002:a17:902:ac85:: with SMTP id h5mr18381885plr.198.1565344367920;
        Fri, 09 Aug 2019 02:52:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565344367; cv=none;
        d=google.com; s=arc-20160816;
        b=jWQB8cqZ2CPSTqLXLy2JIaSiSZ4LavPKYQPO3dHRMU275pepxMfI7vS6dRRG3/ALe7
         WEyhZ4FWVWqf4KUx7A4UfM/Ho5ZjUPS7kNlutKSGwe3mEt/QIGyNgU4cRbw5OCC9V/OJ
         buqnaJlNzWCq7JBNqzRxS/2AAqADH6MAXfrSy2hhYKKllXF1zmpMYuyYEiudVQ+XftKb
         gAk00dXAYJPSb7WCsZLgkE32HVrfsdM9fRPawHYmvVQA7Q3YoB31dDhwRXbseOspcKsX
         P+zC9askgfG5DL5i2LdveJVlFPNngmS00peAK9k1wdrcgtAtn2MAKZYNUP5BOV1b/+ug
         8uJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=coff5jRP+4bBeGfReMXie4tO+oyayDQ9HMdvtmpclDQ=;
        b=JgepBNArZSGPWtXPihlgA6cySUcIu3zA+5QmekV3Mxe3gwldwIEwnYZiFMFxtJiDgv
         Kps/ES5K9mC0Ez+QC/q1pzvYaDg6E2kx03xT01HlzLIhZeC4hE/fcYGc1dqstwbE+pDK
         mx+cd2PXc6expew+6gQ7k14tnmi5ppoMIHRj339MMlWH7gHjKXUqx0SgjSeEw8j+Quto
         Yjc5Bm4lB/xlHgA3MDTPZtT7IGXTKfUheHug4RUesV/7douXNgFMmBLIXIk6mSJUFSrV
         FUmdMWuiw08DAd0UtN14/cDtOP36LMOgkuwJx1pPfVeWMqgv8M8K8RbK196yXvLQJtmQ
         7wjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SNwo9M1M;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a31sor46273284pga.15.2019.08.09.02.52.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 02:52:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SNwo9M1M;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=coff5jRP+4bBeGfReMXie4tO+oyayDQ9HMdvtmpclDQ=;
        b=SNwo9M1MUx6gatXbQ7l9iO1/w+TnVFKCahmmqUAYpyW9H+8n0Cdqfx30RczFbZbRGj
         bf4EOgN0mZk5UpfmOEHDh9Tqi+85r9Nx5aBsfBeQVn6CWgEA5sJK+u1L8ocrYKIIthNn
         2F6M14ipEGBeiPzEROFicAyK7hD9eS/vDy9NYueghQjNprsW0sNm7IxHUP7ML9lzMRIH
         D8m+LDEHZAb3IFfADaHEHE9SI18Ug5QC84E2WuAMCubC9xOKIVg/6C6m6/cA1MrJ6iDp
         0M2Cu2ZuV6JQ9NroGGxGfIvGnRa51kvggywzGBfPcsxpBtJp4gQpVeeEHXR2l75EPd2T
         bx7Q==
X-Google-Smtp-Source: APXvYqwIP7s3exCajcO3pdPQNdIVdIQ8rixRSXZeeayKqB7Lsr3Vn55iMwIIXCcgoE6PDKAdW4jOHg==
X-Received: by 2002:a65:654d:: with SMTP id a13mr16525591pgw.196.1565344367473;
        Fri, 09 Aug 2019 02:52:47 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id e24sm7992122pgk.21.2019.08.09.02.52.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 02:52:47 -0700 (PDT)
Date: Fri, 9 Aug 2019 15:22:36 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: arnd@arndb.de, gregkh@linuxfoundation.org, sivanich@sgi.com,
	ira.weiny@intel.com, jglisse@redhat.com,
	william.kucharski@oracle.com, hch@lst.de,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [Linux-kernel-mentees][PATCH v4 1/1] sgi-gru: Remove *pte_lookup
 functions
Message-ID: <20190809095236.GC22457@bharath12345-Inspiron-5559>
References: <1565290555-14126-1-git-send-email-linux.bhar@gmail.com>
 <1565290555-14126-2-git-send-email-linux.bhar@gmail.com>
 <b659042a-f2c3-df3c-4182-bb7dd5156bc1@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b659042a-f2c3-df3c-4182-bb7dd5156bc1@nvidia.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 04:21:44PM -0700, John Hubbard wrote:
> On 8/8/19 11:55 AM, Bharath Vedartham wrote:
> ...
> >  static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
> >  		    int write, int atomic, unsigned long *gpa, int *pageshift)
> >  {
> >  	struct mm_struct *mm = gts->ts_mm;
> >  	struct vm_area_struct *vma;
> >  	unsigned long paddr;
> > -	int ret, ps;
> > +	int ret;
> > +	struct page *page;
> >  
> >  	vma = find_vma(mm, vaddr);
> >  	if (!vma)
> > @@ -263,21 +187,33 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
> >  
> >  	/*
> >  	 * Atomic lookup is faster & usually works even if called in non-atomic
> > -	 * context.
> > +	 * context. get_user_pages_fast does atomic lookup before falling back to
> > +	 * slow gup.
> >  	 */
> >  	rmb();	/* Must/check ms_range_active before loading PTEs */
> > -	ret = atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
> > -	if (ret) {
> > -		if (atomic)
> > +	if (atomic) {
> > +		ret = __get_user_pages_fast(vaddr, 1, write, &page);
> > +		if (!ret)
> >  			goto upm;
> > -		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))
> > +	} else {
> > +		ret = get_user_pages_fast(vaddr, 1, write ? FOLL_WRITE : 0, &page);
> > +		if (!ret)
> >  			goto inval;
> >  	}
> > +
> > +	paddr = page_to_phys(page);
> > +	put_user_page(page);
> > +
> > +	if (unlikely(is_vm_hugetlb_page(vma)))
> > +		*pageshift = HPAGE_SHIFT;
> > +	else
> > +		*pageshift = PAGE_SHIFT;
> > +
> >  	if (is_gru_paddr(paddr))
> >  		goto inval;
> > -	paddr = paddr & ~((1UL << ps) - 1);
> > +	paddr = paddr & ~((1UL << *pageshift) - 1);
> >  	*gpa = uv_soc_phys_ram_to_gpa(paddr);
> > -	*pageshift = ps;
> 
> Why are you no longer setting *pageshift? There are a couple of callers
> that both use this variable.
I ll send v5 once your convinced by my argument that ps is not necessary
to set *pageshift and that *pageshift is being set.

Thank you
Bharath
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA


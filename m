Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 453C7C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:44:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAF5C2171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:44:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Uj3D0+T2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAF5C2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88AC26B0005; Fri,  9 Aug 2019 05:44:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83AA86B0006; Fri,  9 Aug 2019 05:44:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 728886B0007; Fri,  9 Aug 2019 05:44:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7CA6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 05:44:18 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id m2so8137306pll.18
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 02:44:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0MjjxEATeDSohSUdPgCn+0npRclOTNWQmeqagttLXsE=;
        b=grRmgJC5inJ4Bqz8r6FWRBLe8un40z/ruHrN6ZXhBlbLvFz9Ax4NKHNG1s16M+dAI4
         G0x0mPL4zoWhcsYHCJN/utZhugxdigLwPRxL3JQJPlGL/VVZTId3nE5uTSblRahlQcMb
         jCwK21V2SigOHTbspkTCa661mzmSWecj/MyaZ9brf6LKxu+q1RXN1Wu1ABP/wyJSvJxu
         tK3mrCDhxi9xoRkPMWRrUftiH26MKG02/vA+Rgr97qUU6oU3ic0QNtZ8vPR+F6Rq2h/h
         WrVl7Kl9CnNrFbouPrFo84MDWgF9jMx116uPNANqI4OiaBqq6Fpk8Ahup9kmlQKoThAt
         yPww==
X-Gm-Message-State: APjAAAVdiYkknSficZHQ93sFxXzaTP7Jevo0oWpjbx4RREiBiexJ6mVn
	LdJEFtrAXN4tIXWUX4vdRkhJQ3tlzV/qUAV2KLA5BkLA+DstiWvZNbNK7hzOHlqWSnpvTtUdR0q
	r/W0MZkmdY/oeAITG8lLVuTQ7PVLaCSlOlMrkJkfVgtplUN4VddlmnVux+t6MOUvv5g==
X-Received: by 2002:aa7:83c7:: with SMTP id j7mr3534895pfn.59.1565343857928;
        Fri, 09 Aug 2019 02:44:17 -0700 (PDT)
X-Received: by 2002:aa7:83c7:: with SMTP id j7mr3534835pfn.59.1565343857230;
        Fri, 09 Aug 2019 02:44:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565343857; cv=none;
        d=google.com; s=arc-20160816;
        b=H5WuL936hHjAtWmxblwk9wtladAssHapcE67RBjVsz7fXHxw5LZQlN7aWfl8MmFset
         MME8scP8TZ5qbGGG0hNyzhQl5Pwh74R2CvxnDTb+kQe925xsci32A+ivPcKoz/Me7fTO
         HL83692pab2PLk7xJHGNvYEXrN+63xBZpFs3mQS1bSAV1/vwbkHszvA8dRHFr+Uxq1qt
         Zr3JiJ7FBs0l1mS++VXAmPDiRBQn/QuqOHkn+0k3zMpZhZcgTLydG2z36P2whijuJvtk
         J7TrMkueHwOb+RnFxiQLHwgMsn8OsHU3jmouQqNmpCCc29R/S4L7UVci3gbMd9kokL4S
         r2Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0MjjxEATeDSohSUdPgCn+0npRclOTNWQmeqagttLXsE=;
        b=GPtclY3yE81R++AAasjicWpvtl550w3IjbxLlDTjmODqpLuHr1km4LtPLE3uUxDA/O
         n8P/EIIAD01jmyAkCltQbqjrmpGEr64BvLEZQcrt9wh9yaMQqVp49bduRnrG8+oIaDxX
         UlMezpvvaASBu2dWqJY8Nm+TFveNPfGRZOacsiqmBtM79DH23gR7MyiA1HgbMlLnl3p3
         03ReIKt1idK0n6gsE8Lt5GCuoFSkLZN4/WJaFg5LJxpcaQu/WgBKLdtNT2yl5RqHwl4U
         1rdnjnjT0fvc3tWblE/9eo8n6Cvgal6UVxsDy/9Q8Wm2fmBfvbF7DY/rXtTQci5oPV+5
         IqOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Uj3D0+T2;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g18sor78098774pfo.60.2019.08.09.02.44.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 02:44:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Uj3D0+T2;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=0MjjxEATeDSohSUdPgCn+0npRclOTNWQmeqagttLXsE=;
        b=Uj3D0+T2IeTt2j8R9IQoWagucl2E8dAmOFplTadmEtycTdbXiM6UlavYMVIWRj02Cw
         4nSjNZnzwBdIAEkY38minKr8sYfOUzw8/WLlP8ed8SLzlIhwkZoWRaa1hLLX0HTNpU3l
         +C0O3IoWFhNMlGSkYFNWh5qqg1YWt7jHjjNwXnsLsenEtvNuAmN6uAW6tETi5HZkGIZL
         DrOB+8THq13ltaU/8cqB9++tw1zvfEiBQBoX3Cw1iovi0VSPgY9Yvc4UinD0eWP8t6hd
         ZwvocRvxWFkXtMq3PNSgz9fy8Uktwgue1HOdo+jRr7RaMf3sRku+Hwvkpoi4PR5Myd9g
         ufQw==
X-Google-Smtp-Source: APXvYqwKbvHj8qkjrkEYqfdwuA24Q1Iov787Zkesjq5b/OE+ycYpMk/fRKyoJ/9LftbwlyAmci+LfQ==
X-Received: by 2002:aa7:9254:: with SMTP id 20mr21121887pfp.212.1565343856824;
        Fri, 09 Aug 2019 02:44:16 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id e9sm2925944pfh.155.2019.08.09.02.44.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 02:44:16 -0700 (PDT)
Date: Fri, 9 Aug 2019 15:14:06 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: arnd@arndb.de, gregkh@linuxfoundation.org, sivanich@sgi.com,
	ira.weiny@intel.com, jglisse@redhat.com,
	william.kucharski@oracle.com, hch@lst.de,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [Linux-kernel-mentees][PATCH v4 1/1] sgi-gru: Remove *pte_lookup
 functions
Message-ID: <20190809094406.GA22457@bharath12345-Inspiron-5559>
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
Hi John,

I did set *pageshift. The if statement above sets *pageshift. ps was
used to retrive the pageshift value when the pte_lookup functions were
present. ps was passed by reference to those functions and set by them.
But here since we are trying to remove those functions, we don't need ps
and we directly set *pageshift to HPAGE_SHIFT or PAGE_SHIFT based on the
type of vma. 

Hope this clears things up?

Thank you
Bharath
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA


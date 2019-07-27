Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BD6DC7618B
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 09:23:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2F392080C
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 09:23:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2F392080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF1368E0003; Sat, 27 Jul 2019 05:22:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA0D48E0002; Sat, 27 Jul 2019 05:22:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B910F8E0003; Sat, 27 Jul 2019 05:22:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 857358E0002
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 05:22:42 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l11so13149547pgc.14
        for <linux-mm@kvack.org>; Sat, 27 Jul 2019 02:22:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version:sender
         :precedence:list-id:archived-at:list-archive:list-post
         :content-transfer-encoding;
        bh=d7Y7RUbUctaFTpuaYWlokQeFhmEjck1LGQNsMB3BQ00=;
        b=uhpTSnreEowdQNGVTHO0JsPYi4CEuKL3u6i7gvaA4MrXSpPBjJcvdQW43IgTrnKc9m
         N+Zyi1iOU8T6CCmsbktQl/3rfpY62RjJZAENg4DgF18d0isOmtiV2lbQnAOkUcrkdy4g
         55ldzqi+Yt877lgUC8pcMw015O2MpqIigLpRtH2cY8KwYHsAkJqMDmnlPycrVORPf+W1
         u1ARBRr2kP6ntyIoLkW+uxZZa8CmO/GcZgUncfFon8N2DrJN4RGlONHR321nWfvQ1Bg6
         5Vgm2zEH05P4M7iAJkI/xMlRusGRVbHrJIUetldOjkUjR2+lFYsmvp9FqqYTgNb6qctt
         RS+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.214 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAVk7NMMr1mMrGyv95pbrKFiMcm541fo/UjX0mv0/ZX19h4HvYEh
	Sh62JIbY0AHzvkugR0nZb1ma3ePgRbg81iSjaexkfNoMrWXbgjE0x4rIXTnnLnenosqxr1P3d6T
	Sa/PZb4unOgbzB8KnF80si7UcxJDgpSKxCNLEAtFKHqc8rIfp52MguQ++eFWg3a0J2w==
X-Received: by 2002:a17:902:6ac6:: with SMTP id i6mr101149273plt.233.1564219362159;
        Sat, 27 Jul 2019 02:22:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvc2nXh6DcySwhLTVnWSw2qblScrvj5ZHLt05pPoYMDhMC4jeICR+Mcfdwq8pQ8l5CRF62
X-Received: by 2002:a17:902:6ac6:: with SMTP id i6mr101149228plt.233.1564219361367;
        Sat, 27 Jul 2019 02:22:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564219361; cv=none;
        d=google.com; s=arc-20160816;
        b=C/PErZ8vcbGh/77I8R0PVfIX0RytbHNYNLnRsCFAFMgKyCAuQDN/uszr/VUv1qc1YD
         08iqoyqdQmYu31kuEVAOSvwJCqQk0estT7RspHwYeqggmy1axPhWW/Sv9Bs7csPQJ1pP
         P2rg57owzmYFgNNxSujU58h7IFepZQt9tBAnjZwbhyWFJu6Lb2hJKE3onNjzKzWKbD3b
         FmMgYWu2ZUv4UCaFk8gVflEfDMMWPYGv03ZXIQYyIAxrPoM+xzxCVg1qvc3U32zb+VDu
         boZn3asXt5qeamypK5+dtdKsp5YUSg+zi6kjxQlfXEbRkapyWbjfU9jMHplG2GeQXTHl
         QaCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:sender:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=d7Y7RUbUctaFTpuaYWlokQeFhmEjck1LGQNsMB3BQ00=;
        b=XgHvV89CsnqvrxzmKdqit8eUkJIim2eeqeWnW9mCLwAmI8YQJupFdDyvYFZPYRZl/F
         0TxXJyQlmtg7qMBNpW1i3cbvhgK81dlc7AMZc+4pd/VUTwHLRaGCkMFHuAcqjK4bhc80
         w2SS2FkoPLDlo37SCZ9wkR3n/UEtQWK20CTyg9i8NA8qRj03+lqPD6ENgSQ2vPHxpfKy
         5UuO7t8NOlFqV69VIMz5DpflRP3IbDZznzRNZs0TX0indKUQZwDg3dL6o+yjeoy3TZzz
         FO20g1091Xrjz3ksLTDAwU+n6hfWpcmlTbQP23rh7VkcGxDp1U8//8P7URVHfP60QRqp
         oQiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.214 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail7-214.sinamail.sina.com.cn (mail7-214.sinamail.sina.com.cn. [202.108.7.214])
        by mx.google.com with SMTP id m4si22367613pgv.57.2019.07.27.02.22.40
        for <linux-mm@kvack.org>;
        Sat, 27 Jul 2019 02:22:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.7.214 as permitted sender) client-ip=202.108.7.214;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.214 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([222.131.77.31])
	by sina.com with ESMTP
	id 5D3C17DC00003E9B; Sat, 27 Jul 2019 17:22:39 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 35439950202192
From: Hillf Danton <hdanton@sina.com>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: sivanich@sgi.com,
	arnd@arndb.de,
	ira.weiny@intel.com,
	jhubbard@nvidia.com,
	jglisse@redhat.com,
	gregkh@linuxfoundation.org,
	william.kucharski@oracle.com,
	hch@lst.de,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v3 1/1] sgi-gru: Remove *pte_lookup functions
Date: Sat, 27 Jul 2019 17:22:28 +0800
Message-Id: <1564170120-11882-2-git-send-email-linux.bhar@gmail.com>
In-Reply-To: <1564170120-11882-1-git-send-email-linux.bhar@gmail.com>
References: <1564170120-11882-1-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/1564170120-11882-2-git-send-email-linux.bhar@gmail.com/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190727092228.XllsRDGhGOyPEWHo58xPSCPro1CpujN2jTCLitTC_pk@z>


On Fri, 26 Jul 2019 12:42:26 -0700 (PDT) Bharath Vedartham wrote:
> 
>  static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
>  		    int write, int atomic, unsigned long *gpa, int *pageshift)
>  {
>  	struct mm_struct *mm = gts->ts_mm;
>  	struct vm_area_struct *vma;
>  	unsigned long paddr;
> -	int ret, ps;
> +	int ret;
> +	struct page *page;
>  
>  	vma = find_vma(mm, vaddr);
>  	if (!vma)
> @@ -263,21 +187,33 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
>  
>  	/*
>  	 * Atomic lookup is faster & usually works even if called in non-atomic
> -	 * context.
> +	 * context. get_user_pages_fast does atomic lookup before falling back to
> +	 * slow gup.
>  	 */
>  	rmb();	/* Must/check ms_range_active before loading PTEs */
> -	ret = atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
> -	if (ret) {
> -		if (atomic)
> +	if (atomic) {
> +		ret = __get_user_pages_fast(vaddr, 1, write, &page);
> +		if (!ret)
>  			goto upm;
> -		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))
> +	} else {
> +		ret = get_user_pages_fast(vaddr, 1, write, &page);
> +		if (!ret)
>  			goto inval;
>  	}
> +
> +	paddr = page_to_phys(page);

You may drop find_vma() above if PageHuge(page) makes sense here.

> +	put_user_page(page);
> +
> +	if (unlikely(is_vm_hugetlb_page(vma)))
> +		*pageshift = HPAGE_SHIFT;
> +	else
> +		*pageshift = PAGE_SHIFT;
> +
>  	if (is_gru_paddr(paddr))
>  		goto inval;
> -	paddr = paddr & ~((1UL << ps) - 1);
> -	*gpa = uv_soc_phys_ram_to_gpa(paddr);
> -	*pageshift = ps;
> +	paddr = paddr & ~((1UL << *pageshift) - 1);
> +	*gpa = uv_soc_phys_ram_to_gpa(paddr);
> +
>  	return VTOP_SUCCESS;
>  
>  inval:
> -- 
> 2.7.4


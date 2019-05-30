Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAD19C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 11:17:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A300E25816
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 11:17:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="0PlnzpEV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A300E25816
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 426316B0010; Thu, 30 May 2019 07:17:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FC556B026B; Thu, 30 May 2019 07:17:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C4806B026C; Thu, 30 May 2019 07:17:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CFE576B0010
	for <linux-mm@kvack.org>; Thu, 30 May 2019 07:17:42 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x16so8171186edm.16
        for <linux-mm@kvack.org>; Thu, 30 May 2019 04:17:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=j5JEqVXlVPuBEonAgRReuOAgYKsmvONxrJze6kAXdOo=;
        b=J/xARlDtsk2fwMZP7H0jCPasUxSlf2UKCJWdqfopfKRJluOdt04lDuK5dICSSIpB1b
         lmSf/oc/31yW3h2hUFfq0cAEeeDdgZGoKUYSBzxsksfEYTji/KfhpuJfp7thIJVK97fC
         ROI6fZSY42rI/bTfRY2Z5FA/utaE12VYTLbQ4ZeyZ/HHrVv1KTWsdBNoKozxuzVlacmu
         aU3ZJ8CsnNWEF2362MqWeSUlpBsJmlOUduiITiWDThOBBgbBZsHUVvR9/lIs+jznJOBn
         +ExlTfhZuGGDE/zr0VkLhb+UQvvbeGX4wcKFofBV4jiXd49rcoxMDh1P8/1f7WKYclWF
         DObg==
X-Gm-Message-State: APjAAAWK6gxrp2uJ1ueADuIuj8L+MPHrNSrU10aOQL1zLiEUIFuunf4x
	+iQmSBgY+rdekaXR2QvlumPUdL2wQf9vAzQTmwktTH5l6Mf+W/ceFQI3SSJ8Twe+Xzyxt3I+rsu
	dVNQ+tskkZXBgNkniH8+T+6sKJDggcJ9PX7O0hPCBAJoOXfQJ946XsGPmJEekeaco/A==
X-Received: by 2002:aa7:c891:: with SMTP id p17mr3899301eds.305.1559215062463;
        Thu, 30 May 2019 04:17:42 -0700 (PDT)
X-Received: by 2002:aa7:c891:: with SMTP id p17mr3899244eds.305.1559215061858;
        Thu, 30 May 2019 04:17:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559215061; cv=none;
        d=google.com; s=arc-20160816;
        b=aUXYCGrb2X+YjY8gJY0aG1ihhE6eNyfWBGEd7ibFJFUe4WiUICFWLmshF9gt9TISoq
         rKn1fzKT+9YB8/SWDbEvbqPoMwBRaCqEhSlUWe7b5h7M+VseiyzdRZni4NkJ73YqVCNd
         QXUuSB3YPnArRlwRbe1LPboYHLhQ/SBURbiwmLULPeygPgLTQfx8qAune8fRc45rC1Sz
         b3U0AYWNEJ54yIFyofQW9GOLuwMeASDxQ36MwDKrNRZMsWIBf8MgI7gu5qjVuW+fm80f
         FrcZPZe7sZQUmmYZ29m+gnDdxq11CK5v5bT9qIW2YJjRMOofA5tIn7dYTYRwaMGS3oe9
         poqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=j5JEqVXlVPuBEonAgRReuOAgYKsmvONxrJze6kAXdOo=;
        b=a9uqGfS8ucqzuX2eASFzancsbng6lbfsgrjgq9JGXFYv0TAO1wGJ91ikknLpCpM4sJ
         q0dQof1u2fF8aBTtwscIxy33xsMMkwXZ/UEYMd0FKrWdNmrTwbOmmHkXl9jBwXoTnWEQ
         05L0q+hiprLVtk2P0LOdKUJrqL3vH5Zo711jxiIpFrBeRWuRIcgFhRcfmhAqQvT4oQM+
         F0NA16YHMPpOts4whdF/HFnQtTxfJiVG2lQ4GFIChIGVW/dUP1OwTyZt3xpUEX5qpXCc
         gq4/tjU564YK+xPGtitR96M1hQrvFZfL6B89F2VNHbks5FntL4rC1KnpmUTrDGolF0rt
         Ff5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=0PlnzpEV;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a23sor1378150edy.3.2019.05.30.04.17.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 04:17:41 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=0PlnzpEV;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=j5JEqVXlVPuBEonAgRReuOAgYKsmvONxrJze6kAXdOo=;
        b=0PlnzpEVh/okUS9ehO/eYwgZScgoO1vT9pyY6qDTnILbQOvfTJYA167Nn4JWBH3Ftc
         6Y+hprFUgFL3UPabg+xZjQM+Q9gEZYjg/YtitmOwWeyaEDNggCHOoDsgp+B0yv9An+gl
         3gzP1Y4jLCYGy80AGCaF93qRLcAvXwWRo8jl5xV5a9x4JXvYRYVLjOnGn48uyAcVfRfC
         xuoBjFy3W5MS9zFjl7FgTaYuqaj13MjPxyA//Ggu0VHUX1FpiVa90ajT2iRWLDy2iThk
         2JW3PzhWGP80GjN3M/NuHhj1Jk8p9YFr0XreKy8zOTjODr4dGdccPu989cPJnQlD8WnL
         sjiA==
X-Google-Smtp-Source: APXvYqybXw5+XBpfHSRQmjqUA1kS1y3KdUHm4S7KXKtP9Yh4Mq7RHInPJ+fJ7G/FJg0fkfWxmCkmRA==
X-Received: by 2002:a50:b062:: with SMTP id i89mr3887679edd.85.1559215061571;
        Thu, 30 May 2019 04:17:41 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id m16sm376289ejj.57.2019.05.30.04.17.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 04:17:40 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id B28291041ED; Thu, 30 May 2019 14:17:39 +0300 (+03)
Date: Thu, 30 May 2019 14:17:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, namit@vmware.com,
	peterz@infradead.org, oleg@redhat.com, rostedt@goodmis.org,
	mhiramat@kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, chad.mynhier@oracle.com,
	mike.kravetz@oracle.com
Subject: Re: [PATCH uprobe, thp 2/4] uprobe: use original page when all
 uprobes are removed
Message-ID: <20190530111739.r6b2hpzjadep4xr5@box>
References: <20190529212049.2413886-1-songliubraving@fb.com>
 <20190529212049.2413886-3-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529212049.2413886-3-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 02:20:47PM -0700, Song Liu wrote:
> @@ -501,6 +512,20 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
>  	copy_highpage(new_page, old_page);
>  	copy_to_page(new_page, vaddr, &opcode, UPROBE_SWBP_INSN_SIZE);
>  
> +	index = vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
> +	orig_page = find_get_page(vma->vm_file->f_inode->i_mapping, index);
> +	if (orig_page) {
> +		if (memcmp(page_address(orig_page),
> +			   page_address(new_page), PAGE_SIZE) == 0) {

Does it work for highmem?


-- 
 Kirill A. Shutemov


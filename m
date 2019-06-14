Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01FB2C31E4E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 19:00:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2B802177E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 19:00:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="vyoR8waO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2B802177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 608F46B000C; Fri, 14 Jun 2019 15:00:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B99C6B000D; Fri, 14 Jun 2019 15:00:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4818C6B000E; Fri, 14 Jun 2019 15:00:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 123526B000C
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 15:00:39 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id c3so2099249plr.16
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:00:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=42tVzP969KSuSvAVe/L566sbhyraQii/h1IwyWVNDUc=;
        b=moAZ0Z9TOgpS7i4b3sYwE1fysCUOl330vHZoQXjWbCT1iP0K1M/qXarDO2d4MYQFG/
         nimroboiEZOvhRWvdPdOJyKHbgHF9B2wdM3oJytvnvUkvVDFx8QLNdaQJTjkf2n3p5eh
         xYFsqFsmQ9yCENaXI/p61vqUMSiXdNnpipyb5llXTDPBiENlfT4bOrq8yG3iCjBkDP2W
         +ZIXvrjkzz1BTQmMdAI5tG49Jd4TJfZu+R1syvxXjIgOwjnZdt7dfNthqCpxl81Gjlku
         BSEa9tlMVizRGm8HC8hyXbFmfu45/yAvUPX8omChQOJBd4MN7WsxdKNTazFUu/E5KEyN
         ZNXQ==
X-Gm-Message-State: APjAAAU3UWc6inl7muz5Lg87O+2wHTZQa01I7CWvvJneFRpZcozS0wAS
	h9ChRUppbhs8Q3lggJBCo2uPOB9R2QU+Ft7sI6XS9eftuiAFxvGeNOxb2b/rx3HgLH+TktSNReB
	D5x+04iCDmzWwF+OoLWOHabchfDlh3ATFRjj+gbHb5D0V7XSgN8Z8/9nqkycvUIs8kA==
X-Received: by 2002:a62:6844:: with SMTP id d65mr101097315pfc.175.1560538838636;
        Fri, 14 Jun 2019 12:00:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqIWXJZCr2Tl0UIlMnM/Cnrv23/WubIICBuhTCYK9BO4zz4OpKdQs9IqPi9/toJ3nTn8lC
X-Received: by 2002:a62:6844:: with SMTP id d65mr101097265pfc.175.1560538837964;
        Fri, 14 Jun 2019 12:00:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560538837; cv=none;
        d=google.com; s=arc-20160816;
        b=af+X2JuGHtfQ6GocT/kZN2auENa7K4qip3fBmBOinm39S0bLrwiZTcJEtKoGzvrXvc
         Vp1Spg9b08AWW6iBLYztNsf9jbVIdd8sCsrshxgI78o2SF0KhBFmsLil7gzIUDSgll8+
         yXVfrkClouWD1Ip+2LxelBF7/QAxx2VvZ351hYYJtOSNlS+5ok450bsV25CRm4aXL3kx
         CwIS87w3bUD+jQDDLniAbIkv+66Mt22EwAiaoni335J905mJemmnpCp0HA9RYxSKIlJJ
         6SQrVFuqvHyfOcuAbwq8fkZrNCbUb7HIF4odREskdFnnIf93ngpdVZgzOg9mPbHvORVF
         2qDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=42tVzP969KSuSvAVe/L566sbhyraQii/h1IwyWVNDUc=;
        b=lBtnxDLoh/O6QgbvmWNaI99yg05KJID9Hgc8VW0w+K1X4jtOJbgdpetasdNZaiYPfQ
         XVP8zsQ9FveyvP4txclrPMuOt7oVDrWpGaWmNFsDqZigGqqvrwgT4gBjfL0YnJcAsOx2
         QbjEig67yD4y37R+sSg5Mh41dkWYL6Zbfy2zeRufHGvnrtrXe+dMy+oIx/NekdZX65FB
         /Gw3ZlFKiEHjtEzgNJx+ypL7SkI2x+i9pzUt/L0IbqXOFka2hACXz92NG23E2ivsKxOu
         A184U0bjaYA6lkx9L40+AEWPf1R33q7uNDH2GYsHU/RRWfsTh8CSQ5vA20X8ml6Yaz1S
         Gd3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vyoR8waO;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j20si2921133pjn.6.2019.06.14.12.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 12:00:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=vyoR8waO;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C09DD21473;
	Fri, 14 Jun 2019 19:00:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560538837;
	bh=9luYIMc1miTz2FraniCesV9+ZaFoX/edSHhy+mT9JIY=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=vyoR8waOE1q5W/EKmFkQ9Obg/5StU3mMk8E+LGCQxdywY0BsyK2eX1sdrt42y9dRV
	 wYeOCumqHytulVpdq9L/T+kBFZ7QQeib24BW3MLVlfdYP1kco4m9Vt74OTz/3IltiR
	 zqJDvkwvBiUrUZcglCfj5SjZmdUbtzRIl2y26arw=
Date: Fri, 14 Jun 2019 12:00:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>,
 linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org,
 linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
 Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>,
 Wei Yang <richard.weiyang@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Arun KS <arunks@codeaurora.org>, Pavel Tatashin
 <pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@suse.de>, Stephen
 Rothwell <sfr@canb.auug.org.au>, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v1 1/6] mm: Section numbers use the type "unsigned long"
Message-Id: <20190614120036.00ae392e3f210e7bc9ec6960@linux-foundation.org>
In-Reply-To: <20190614100114.311-2-david@redhat.com>
References: <20190614100114.311-1-david@redhat.com>
	<20190614100114.311-2-david@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Jun 2019 12:01:09 +0200 David Hildenbrand <david@redhat.com> wrote:

> We are using a mixture of "int" and "unsigned long". Let's make this
> consistent by using "unsigned long" everywhere. We'll do the same with
> memory block ids next.
> 
> ...
>
> -	int i, ret, section_count = 0;
> +	unsigned long i;
>
> ...
>
> -	unsigned int i;
> +	unsigned long i;

Maybe I did too much fortran back in the day, but I think the
expectation is that a variable called "i" has type "int".

This?



s/unsigned long i/unsigned long section_nr/

--- a/drivers/base/memory.c~mm-section-numbers-use-the-type-unsigned-long-fix
+++ a/drivers/base/memory.c
@@ -131,17 +131,17 @@ static ssize_t phys_index_show(struct de
 static ssize_t removable_show(struct device *dev, struct device_attribute *attr,
 			      char *buf)
 {
-	unsigned long i, pfn;
+	unsigned long section_nr, pfn;
 	int ret = 1;
 	struct memory_block *mem = to_memory_block(dev);
 
 	if (mem->state != MEM_ONLINE)
 		goto out;
 
-	for (i = 0; i < sections_per_block; i++) {
-		if (!present_section_nr(mem->start_section_nr + i))
+	for (section_nr = 0; section_nr < sections_per_block; section_nr++) {
+		if (!present_section_nr(mem->start_section_nr + section_nr))
 			continue;
-		pfn = section_nr_to_pfn(mem->start_section_nr + i);
+		pfn = section_nr_to_pfn(mem->start_section_nr + section_nr);
 		ret &= is_mem_section_removable(pfn, PAGES_PER_SECTION);
 	}
 
@@ -695,12 +695,12 @@ static int add_memory_block(unsigned lon
 {
 	int ret, section_count = 0;
 	struct memory_block *mem;
-	unsigned long i;
+	unsigned long section_nr;
 
-	for (i = base_section_nr;
-	     i < base_section_nr + sections_per_block;
-	     i++)
-		if (present_section_nr(i))
+	for (section_nr = base_section_nr;
+	     section_nr < base_section_nr + sections_per_block;
+	     section_nr++)
+		if (present_section_nr(section_nr))
 			section_count++;
 
 	if (section_count == 0)
@@ -823,7 +823,7 @@ static const struct attribute_group *mem
  */
 int __init memory_dev_init(void)
 {
-	unsigned long i;
+	unsigned long section_nr;
 	int ret;
 	int err;
 	unsigned long block_sz;
@@ -840,9 +840,9 @@ int __init memory_dev_init(void)
 	 * during boot and have been initialized
 	 */
 	mutex_lock(&mem_sysfs_mutex);
-	for (i = 0; i <= __highest_present_section_nr;
-		i += sections_per_block) {
-		err = add_memory_block(i);
+	for (section_nr = 0; section_nr <= __highest_present_section_nr;
+		section_nr += sections_per_block) {
+		err = add_memory_block(section_nr);
 		if (!ret)
 			ret = err;
 	}
_


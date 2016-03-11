Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2DCFA6B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 16:40:21 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id m7so125932913obh.3
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 13:40:21 -0800 (PST)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id b2si7956910oem.44.2016.03.11.13.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 13:40:20 -0800 (PST)
Received: by mail-ob0-x229.google.com with SMTP id fz5so126359950obc.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 13:40:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1457730784-9890-2-git-send-email-matthew.r.wilcox@intel.com>
References: <1457730784-9890-1-git-send-email-matthew.r.wilcox@intel.com>
	<1457730784-9890-2-git-send-email-matthew.r.wilcox@intel.com>
Date: Fri, 11 Mar 2016 13:40:20 -0800
Message-ID: <CAPcyv4g82US298_mCd75toj9kEeyDhw0cP_Ott0R8fOydWNsSg@mail.gmail.com>
Subject: Re: [PATCH 1/3] pfn_t: Change the encoding
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Matthew Wilcox <willy@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri, Mar 11, 2016 at 1:13 PM, Matthew Wilcox
<matthew.r.wilcox@intel.com> wrote:
> By moving the flag bits to the bottom, we encourage commonality
> between SGs with pages and those using pfn_t.  We can also then insert
> a pfn_t into a radix tree, as it uses the same two bits for indirect &
> exceptional indicators.

It's not immediately clear to me what we gain with SG entry
commonality.  The down side is that we lose the property that
pfn_to_pfn_t() is a nop.  This was Dave's suggestion so that the
nominal case did not change the binary layout of a typical pfn.

Can we just bit swizzle a pfn_t on insertion/retrieval from the radix?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 264DD6B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 15:56:55 -0500 (EST)
Received: by wmec201 with SMTP id c201so122629564wme.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 12:56:54 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id db10si21828203wjc.200.2015.11.23.12.56.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 12:56:54 -0800 (PST)
Received: by wmec201 with SMTP id c201so122629211wme.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 12:56:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1448311559.19320.2.camel@hpe.com>
References: <1448309120-20911-1-git-send-email-toshi.kani@hpe.com>
	<CAPcyv4ibgtMJdKG19vaS_s2_eFy8ufZm92G2DH6N7brDiE+LYA@mail.gmail.com>
	<1448311559.19320.2.camel@hpe.com>
Date: Mon, 23 Nov 2015 12:56:53 -0800
Message-ID: <CAPcyv4hafiv+EJaWGDhrV4Fe7=h=naALTwY0b=pfC2yfS7NShw@mail.gmail.com>
Subject: Re: [PATCH] dax: Split pmd map when fallback on COW
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Nov 23, 2015 at 12:45 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> On Mon, 2015-11-23 at 12:45 -0800, Dan Williams wrote:
>> On Mon, Nov 23, 2015 at 12:05 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
[..]
>> This is a nop if CONFIG_TRANSPARENT_HUGEPAGE=n, so I don't think it's
>> a complete fix.
>
> Well, __dax_pmd_fault() itself depends on CONFIG_TRANSPARENT_HUGEPAGE.
>

Indeed it is... I think that's wrong because transparent huge pages
rely on struct page??

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA5B6B025E
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 05:33:01 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l68so25534608wml.3
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:33:01 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id r134si19907897wmd.40.2016.09.13.02.33.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 02:33:00 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id 1so190009949wmz.1
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:33:00 -0700 (PDT)
Date: Tue, 13 Sep 2016 12:32:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC] mm: Change the data type of huge page size from unsigned
 long to u64
Message-ID: <20160913093257.GA31186@node>
References: <1473758765-13673-1-git-send-email-rui.teng@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1473758765-13673-1-git-send-email-rui.teng@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Teng <rui.teng@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Chen Gang <chengang@emindsoft.com.cn>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, hejianet@linux.vnet.ibm.com

On Tue, Sep 13, 2016 at 05:26:05PM +0800, Rui Teng wrote:
> The huge page size could be 16G(0x400000000) on ppc64 architecture, and it will
> cause an overflow on unsigned long data type(0xFFFFFFFF).

Huh? ppc64 is 64-bit system and sizeof(void *) is equal to
sizeof(unsigned long) on Linux (LP64 model).

So where your 0xFFFFFFFF comes from?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

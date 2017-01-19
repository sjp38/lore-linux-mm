Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 542F06B02D6
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 17:11:31 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id v73so70414765ywg.2
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 14:11:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h184si3526012qkf.91.2017.01.19.14.11.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 14:11:30 -0800 (PST)
Date: Thu, 19 Jan 2017 23:11:26 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2 1/1] mm/ksm: improve deduplication of zero pages with
 colouring
Message-ID: <20170119221126.GP10177@redhat.com>
References: <1484850953-23941-1-git-send-email-imbrenda@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484850953-23941-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, borntraeger@de.ibm.com, hughd@google.com, chrisw@sous-sol.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Hello,

On Thu, Jan 19, 2017 at 07:35:53PM +0100, Claudio Imbrenda wrote:
> +/* Checksum of an empty (zeroed) page */
> +static unsigned int zero_checksum;
> +
> +/* Whether to merge empty (zeroed) pages with actual zero pages */
> +static bool ksm_use_zero_pages;

Both could be defined as __read_mostly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

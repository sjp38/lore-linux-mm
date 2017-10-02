Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE9516B0253
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 17:47:26 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id w94so4917594ioi.10
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 14:47:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q7si4598787oig.34.2017.10.02.14.47.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 14:47:26 -0700 (PDT)
Date: Mon, 2 Oct 2017 17:47:23 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/hmm: constify hmm_devmem_page_get_drvdata() parameter
Message-ID: <20171002214722.GA5184@redhat.com>
References: <1506972774-10191-1-git-send-email-jglisse@redhat.com>
 <20171002144042.e33ff3cf7dc95845e255d2c0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171002144042.e33ff3cf7dc95845e255d2c0@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>

On Mon, Oct 02, 2017 at 02:40:42PM -0700, Andrew Morton wrote:
> On Mon,  2 Oct 2017 15:32:54 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > From: Ralph Campbell <rcampbell@nvidia.com>
> > 
> > Constify pointer parameter to avoid issue when use from code that
> > only has const struct page pointer to use in the first place.
> 
> That's rather vague.  Does such calling code exist in the kernel?  This
> affects the which-kernel-gets-patched decision.

This is use by device driver, no driver upstream yet so it does not
affect anybody upstream yet.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

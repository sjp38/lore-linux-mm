Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id BF1796B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 15:57:30 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id gl10so1978079lab.32
        for <linux-mm@kvack.org>; Wed, 21 May 2014 12:57:29 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id ln10si21401751lac.102.2014.05.21.12.57.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 12:57:29 -0700 (PDT)
Received: by mail-la0-f54.google.com with SMTP id pv20so1981149lab.13
        for <linux-mm@kvack.org>; Wed, 21 May 2014 12:57:28 -0700 (PDT)
Date: Wed, 21 May 2014 23:57:23 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: /prom/pid/clear_refs: avoid split_huge_page()
Message-ID: <20140521195723.GD12819@moon>
References: <1400699062-20123-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20140521123446.ae45fa676cae27fffbd96cfd@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140521123446.ae45fa676cae27fffbd96cfd@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Dave Hansen <dave.hansen@intel.com>

On Wed, May 21, 2014 at 12:34:46PM -0700, Andrew Morton wrote:
> On Wed, 21 May 2014 22:04:22 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > Currently we split all THP pages on any clear_refs request. It's not
> > necessary. We can handle this on PMD level.
> > 
> > One side effect is that soft dirty will potentially see more dirty
> > memory, since we will mark whole THP page dirty at once.
> 
> This clashes pretty badly with
> http://ozlabs.org/~akpm/mmots/broken-out/clear_refs-redefine-callback-functions-for-page-table-walker.patch
> 
> > Sanity checked with CRIU test suite. More testing is required.
> 
> Will you be doing that testing or was this a request for Cyrill & co to
> help?

We've talking to Kirill how to test is and end up that criu is
the best candidate (though I think I'll write selftest for
vanilla too, hopefully tomorrow).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

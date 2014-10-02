Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 917E26B0038
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 20:25:33 -0400 (EDT)
Received: by mail-ig0-f174.google.com with SMTP id l13so1218586iga.7
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 17:25:33 -0700 (PDT)
Received: from mail-ie0-x249.google.com (mail-ie0-x249.google.com [2607:f8b0:4001:c03::249])
        by mx.google.com with ESMTPS id bc4si7053804icc.72.2014.10.01.17.25.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 17:25:32 -0700 (PDT)
Received: by mail-ie0-f201.google.com with SMTP id rl12so220101iec.4
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 17:25:31 -0700 (PDT)
Date: Wed, 1 Oct 2014 17:25:30 -0700
From: Peter Feiner <pfeiner@google.com>
Subject: Re: [PATCH v2] mm: softdirty: unmapped addresses between VMAs are
 clean
Message-ID: <20141002002530.GF7019@google.com>
References: <1410391486-9106-1-git-send-email-pfeiner@google.com>
 <1410806438-7496-1-git-send-email-pfeiner@google.com>
 <20140926203326.GA12422@nhori.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140926203326.GA12422@nhori.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Sep 26, 2014 at 04:33:26PM -0400, Naoya Horiguchi wrote:
> Could you test and merge the following change?

Many apologies for the late reply! Your email was in my spam folder :-( I see
that Andrew has already merged the patch, so we're in good shape!

Thanks for fixing this bug Naoya!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

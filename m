Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 789096B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 16:02:30 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so9198830pdj.34
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 13:02:30 -0700 (PDT)
Received: by mail-la0-f50.google.com with SMTP id gx14so7546578lab.9
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 13:02:25 -0700 (PDT)
Date: Wed, 9 Oct 2013 00:02:24 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 0/3] Soft dirty tracking fixes
Message-ID: <20131008200224.GB19040@moon>
References: <20131008090019.527108154@gmail.com>
 <20131008125013.85dcccf418260d43b6cb120a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131008125013.85dcccf418260d43b6cb120a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 08, 2013 at 12:50:13PM -0700, Andrew Morton wrote:
> 
> Do you consider the problems which patches 1 and 2 address to be
> sufficiently serious to justify backporting into -stable?

Good question! Yeah, since dirty bit traking is in 3.11 already,
it would be great to merge these two patches into -stable.
Should I resend them with stable team CC'ed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

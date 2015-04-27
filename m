Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f46.google.com (mail-vn0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 51B1E6B006E
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 03:44:15 -0400 (EDT)
Received: by vnbf190 with SMTP id f190so10886295vnb.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 00:44:15 -0700 (PDT)
Received: from mail-vn0-x231.google.com (mail-vn0-x231.google.com. [2607:f8b0:400c:c0f::231])
        by mx.google.com with ESMTPS id wb8si29017098vdc.94.2015.04.27.00.44.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 00:44:14 -0700 (PDT)
Received: by vnbf62 with SMTP id f62so10885977vnb.3
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 00:44:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1430119993-7358-1-git-send-email-robsonde@gmail.com>
References: <1430119993-7358-1-git-send-email-robsonde@gmail.com>
Date: Mon, 27 Apr 2015 09:44:14 +0200
Message-ID: <CAFLxGvyYH4c+YKaRkgztXzLA9sPk+7fPYbdmxd=1528HE_Vb7A@mail.gmail.com>
Subject: Re: [PATCH] mm: fixed whitespace style errors in failslab.c
From: Richard Weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Derek Robson <robsonde@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 27, 2015 at 9:33 AM, Derek Robson <robsonde@gmail.com> wrote:
> This patch fixes a white space issue found with checkpatch.pl in failslab.c
> ERROR: code indent should use tabs where possible
>
> Added a tab to replace the spaces to meet the preferred style.
>
> Signed-off-by: Derek Robson <robsonde@gmail.com>
> ---
>  mm/failslab.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Running checkpatch.pl against in-tree files is not really useful.
Especially if you "fix" only whitespace stuff.
Most maintainers agree that it is not worth the maintenance overhead
and the git history pollution.

Please stick to drivers/staging/ or fix real issues. :-)

-- 
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

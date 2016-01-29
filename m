Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id EFD236B025F
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 22:54:49 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id dx2so34406129lbd.3
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 19:54:49 -0800 (PST)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id l200si7108627lfg.21.2016.01.28.19.54.48
        for <linux-mm@kvack.org>;
        Thu, 28 Jan 2016 19:54:48 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCHv2 2/2] mm/page_poisoning.c: Allow for zero poisoning
Date: Fri, 29 Jan 2016 04:55:44 +0100
Message-ID: <2210767.i4rORgf7qQ@vostro.rjw.lan>
In-Reply-To: <1454035099-31583-3-git-send-email-labbott@fedoraproject.org>
References: <1454035099-31583-1-git-send-email-labbott@fedoraproject.org> <1454035099-31583-3-git-send-email-labbott@fedoraproject.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>, linux-pm@vger.kernel.org

On Thursday, January 28, 2016 06:38:19 PM Laura Abbott wrote:
> By default, page poisoning uses a poison value (0xaa) on free. If this
> is changed to 0, the page is not only sanitized but zeroing on alloc
> with __GFP_ZERO can be skipped as well. The tradeoff is that detecting
> corruption from the poisoning is harder to detect. This feature also
> cannot be used with hibernation since pages are not guaranteed to be
> zeroed after hibernation.
> 
> Credit to Grsecurity/PaX team for inspiring this work
> 
> Signed-off-by: Laura Abbott <labbott@fedoraproject.org>

The hibernation disabling part is fine by me.

Please feel free to add an ACK from me to this if that helps.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

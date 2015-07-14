Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D6074280257
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:52:54 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so10321123pdb.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:52:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id sh10si3274627pbb.6.2015.07.14.11.52.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 11:52:54 -0700 (PDT)
Date: Tue, 14 Jul 2015 11:52:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHSET v4 0/5] pagemap: make useable for non-privilege users
Message-Id: <20150714115252.8f21cfa864935a4b403c3d8d@linux-foundation.org>
In-Reply-To: <20150714152516.29844.69929.stgit@buzz>
References: <20150714152516.29844.69929.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mark Williamson <mwilliamson@undo-software.com>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Tue, 14 Jul 2015 18:37:34 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:

> This patchset makes pagemap useable again in the safe way (after row hammer
> bug it was made CAP_SYS_ADMIN-only). This patchset restores access for
> non-privileged users but hides PFNs from them.

Documentation/vm/pagemap.txt hasn't been updated to describe these
privilege issues?

> Also it adds bit 'map-exlusive' which is set if page is mapped only here:
> it helps in estimation of working set without exposing pfns and allows to
> distinguish CoWed and non-CoWed private anonymous pages.
> 
> Second patch removes page-shift bits and completes migration to the new
> pagemap format: flags soft-dirty and mmap-exlusive are available only
> in the new format.

I'm not really seeing a description of the new format in these
changelogs.  Precisely what got removed, what got added and which
capabilities change the output in what manner?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

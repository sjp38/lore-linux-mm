Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3D86B0038
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 16:25:13 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x23so45097029pgx.6
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 13:25:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 90si20914547plb.305.2016.12.06.13.25.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 13:25:10 -0800 (PST)
Date: Tue, 6 Dec 2016 13:25:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 33/33] Reimplement IDR and IDA using the radix tree
Message-Id: <20161206132538.e474083ae851c7284bb89b2a@linux-foundation.org>
In-Reply-To: <CY1PR21MB0071D603E8B6F6A7F820492BCB820@CY1PR21MB0071.namprd21.prod.outlook.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
	<1480369871-5271-34-git-send-email-mawilcox@linuxonhyperv.com>
	<20161206124453.3d3ce26a1526fedd70988ab8@linux-foundation.org>
	<CY1PR21MB0071D603E8B6F6A7F820492BCB820@CY1PR21MB0071.namprd21.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Matthew Wilcox <mawilcox@linuxonhyperv.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>

On Tue, 6 Dec 2016 21:17:52 +0000 Matthew Wilcox <mawilcox@microsoft.com> wrote:

> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> > On Mon, 28 Nov 2016 13:50:37 -0800 Matthew Wilcox
> > <mawilcox@linuxonhyperv.com> wrote:
> > >  include/linux/idr.h                     |  132 ++--
> > >  include/linux/radix-tree.h              |    5 +-
> > >  init/main.c                             |    3 +-
> > >  lib/idr.c                               | 1078 -------------------------------
> > >  lib/radix-tree.c                        |  632 ++++++++++++++++--
> > 
> > hm.  It's just a cosmetic issue, but perhaps the idr
> > wrappers-around-radix-tree code should be in a different .c file.
> 
> I can put some of them back into idr.c -- there's a couple of routines left in there still, so adding some more won't hurt.

OK.  Sometime.  Let's see how this lot pans out as-is for now?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

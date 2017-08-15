Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9DA6B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 11:11:25 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id f69so11756670ioe.10
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 08:11:25 -0700 (PDT)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [2001:558:fe16:19:96:114:154:165])
        by mx.google.com with ESMTPS id a75si9466424ioa.80.2017.08.15.08.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 08:11:24 -0700 (PDT)
Date: Tue, 15 Aug 2017 10:11:22 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: How can we share page cache pages for reflinked files?
In-Reply-To: <20170814210959.r4mdv3y4rdeolyxt@node.shutemov.name>
Message-ID: <alpine.DEB.2.20.1708151009440.8223@nuc-kabylake>
References: <20170810042849.GK21024@dastard> <20170810161159.GI31390@bombadil.infradead.org> <20170811042519.GS21024@dastard> <20170811170847.GK31390@bombadil.infradead.org> <20170814064838.GB21024@dastard> <alpine.DEB.2.20.1708141307380.32429@nuc-kabylake>
 <20170814210959.r4mdv3y4rdeolyxt@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, 15 Aug 2017, Kirill A. Shutemov wrote:

> > This would also allow the inevitable creeping page struct bloat to get
> > completely out of control.
>
> Nice wish list. Add pony. :)
>
> Any attempt to replace struct page with something more complex will have
> severe performance implications. I'll be glad proved otherwise.

Do we care that much anymore? I have people inserting all sorts of runtime
checks into hotpaths in the name of security.....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

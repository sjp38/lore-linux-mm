Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A3AFA6B025E
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 09:59:16 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id v21so9026787iob.0
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 06:59:16 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id l4si4568898iol.170.2017.12.19.06.59.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 06:59:15 -0800 (PST)
Date: Tue, 19 Dec 2017 08:59:14 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 2/8] mm: De-indent struct page
In-Reply-To: <20171218214455.GA31673@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1712190859000.16727@nuc-kabylake>
References: <20171216164425.8703-1-willy@infradead.org> <20171216164425.8703-3-willy@infradead.org> <20171218153652.GC3876@dhcp22.suse.cz> <20171218161902.GA688@bombadil.infradead.org> <20171218204935.GU16951@dhcp22.suse.cz>
 <20171218214455.GA31673@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Mon, 18 Dec 2017, Matthew Wilcox wrote:

> On Mon, Dec 18, 2017 at 09:49:35PM +0100, Michal Hocko wrote:
> > Excelent! Could you add the later one to the changelog please? With
> > that
> > Acked-by: Michal Hocko <mhocko@suse.com>
> >
> > I will go over the rest of the series tomorrow.
>
> Thanks!  I've added Kirill's and Randy's Acks/Reviews too.  Christoph,
> any chance you'd be able to provide an ack on this?

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

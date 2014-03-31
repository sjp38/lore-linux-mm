Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 735CF6B0037
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 19:53:26 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so8932863pbc.16
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 16:53:26 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id dg5si10033924pbc.179.2014.03.31.16.53.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Mar 2014 16:53:25 -0700 (PDT)
Date: Mon, 31 Mar 2014 16:55:43 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [patch stable-3.10] mm: close PageTail race
Message-ID: <20140331235543.GB20979@kroah.com>
References: <alpine.DEB.2.02.1403281333290.18841@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1403281333290.18841@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: stable@vger.kernel.org, Holger Kiehl <Holger.Kiehl@dwd.de>, Christoph Lameter <cl@linux.com>, Rafael Aquini <aquini@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 28, 2014 at 01:35:34PM -0700, David Rientjes wrote:
> commit 668f9abbd4334e6c29fa8acd71635c4f9101caa7 upstream.

Applied, thanks.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

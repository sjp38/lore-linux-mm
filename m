Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1606B014A
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 03:27:39 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id wy17so271432pbc.0
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 00:27:39 -0800 (PST)
Received: from psmtp.com ([74.125.245.172])
        by mx.google.com with SMTP id yk3si2161411pac.215.2013.11.07.00.27.37
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 00:27:38 -0800 (PST)
Date: Thu, 7 Nov 2013 09:27:32 +0100
From: Andreas Herrmann <andreas.herrmann@calxeda.com>
Subject: Re: [PATCH] mm/slub: Switch slub_debug kernel option to early_param
 to avoid boot panic
Message-ID: <20131107082732.GN5661@alberich>
References: <20131106184529.GB5661@alberich>
 <000001422ed8406b-14bef091-eee0-4e0e-bcdd-a8909c605910-000000@email.amazonses.com>
 <20131106195417.GK5661@alberich>
 <20131106203429.GL5661@alberich>
 <20131106211604.GM5661@alberich>
 <000001422f59e79e-ba0d30e2-fe7d-4e6f-9029-65dc5978fe60-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <000001422f59e79e-ba0d30e2-fe7d-4e6f-9029-65dc5978fe60-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Nov 06, 2013 at 04:38:10PM -0500, Christoph Lameter wrote:
> On Wed, 6 Nov 2013, Andreas Herrmann wrote:
> 
> > Would be nice, if your patch is pushed upstream asap.
> 
> Ok so this is a
> 
> Tested-by: Andreas Herrmann <andreas.herrmann@calxeda.com>
> 
> I think?

Yes.

> BTW Calxeda is a great product. Hope you get 64 bit running soon.


Thanks,

Andreas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

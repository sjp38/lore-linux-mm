Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB2382F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 10:40:07 -0500 (EST)
Received: by igbdj2 with SMTP id dj2so14835762igb.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 07:40:07 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id e19si21132328ioi.48.2015.11.03.07.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 07:40:06 -0800 (PST)
Received: by padhx2 with SMTP id hx2so13745920pad.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 07:40:06 -0800 (PST)
Date: Tue, 3 Nov 2015 07:39:53 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] osd fs: __r4w_get_page rely on PageUptodate for
 uptodate
In-Reply-To: <56387D3C.5020003@plexistor.com>
Message-ID: <alpine.LSU.2.11.1511030734300.1856@eggly.anvils>
References: <alpine.LSU.2.11.1510291137430.3369@eggly.anvils> <5635E2B4.5070308@electrozaur.com> <alpine.LSU.2.11.1511011513240.11427@eggly.anvils> <5637437C.4070306@electrozaur.com> <alpine.LSU.2.11.1511021813010.1013@eggly.anvils>
 <56387D3C.5020003@plexistor.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Lameter <cl@linux.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, osd-dev@open-osd.org

On Tue, 3 Nov 2015, Boaz Harrosh wrote:
> On 11/03/2015 04:49 AM, Hugh Dickins wrote:
> > On Mon, 2 Nov 2015, Boaz Harrosh wrote:
> >>
> >> Do you think the code is actually wrong as is?
> > 
> > Not that I know of: just a little too complicated and confusing.
> > 
> > But becomes slightly wrong if my simplification to page migration
> > goes through, since that introduces an instant when PageDirty is set
> > before the new page contains the correct data and is marked Uptodate.
> > Hence my patch.
> > 
> >>
> >> BTW: Very similar code is in fs/nfs/objlayout/objio_osd.c::__r4w_get_page
> > 
> > Indeed, the patch makes the same adjustment to that code too.
> > 
> 
> OK thanks. Let me setup and test your patch. On top of 4.3 is good?
> I'll send you a tested-by once I'm done.

Great, thanks Boaz, that will help a lot.  On top of 4.3 very good.

(Of course, that will not test the rare page migration race I shall
introduce later; but it will test that you're doing the right thing
with this change at your end, when you will be safe against the race.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

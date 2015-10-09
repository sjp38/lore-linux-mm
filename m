Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 52C0D82F64
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 09:34:55 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so70939581wic.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 06:34:54 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id gc14si4533528wic.73.2015.10.09.06.34.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 06:34:54 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so67519548wic.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 06:34:52 -0700 (PDT)
Date: Fri, 9 Oct 2015 16:34:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3] mm,thp: reduce ifdef'ery for THP in generic code
Message-ID: <20151009133450.GA8597@node>
References: <1444391029-25332-1-git-send-email-vgupta@synopsys.com>
 <5617BB4A.4040704@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5617BB4A.4040704@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Oct 09, 2015 at 06:34:10PM +0530, Vineet Gupta wrote:
> On Friday 09 October 2015 05:13 PM, Vineet Gupta wrote:
> > - pgtable-generic.c: Fold individual #ifdef for each helper into a top
> >   level #ifdef. Makes code more readable
> > 
> > - Converted the stub helpers for !THP to BUILD_BUG() vs. runtime BUG()
> > 
> > Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
> 
> Sorry for sounding pushy - an Ack here will unblock me from dumping boat load of
> patches into linux-next via my tree !

I hope you've tested it with different .configs...

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

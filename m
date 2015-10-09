Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF4E6B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 09:41:27 -0400 (EDT)
Received: by iofh134 with SMTP id h134so91321255iof.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 06:41:27 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id rh3si11165637igc.34.2015.10.09.06.41.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 06:41:26 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH v3] mm,thp: reduce ifdef'ery for THP in generic code
Date: Fri, 9 Oct 2015 13:39:31 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075D781C2C9@IN01WEMBXB.internal.synopsys.com>
References: <1444391029-25332-1-git-send-email-vgupta@synopsys.com>
 <5617BB4A.4040704@synopsys.com> <20151009133450.GA8597@node>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Friday 09 October 2015 07:04 PM, Kirill A. Shutemov wrote:

On Fri, Oct 09, 2015 at 06:34:10PM +0530, Vineet Gupta wrote:


> On Friday 09 October 2015 05:13 PM, Vineet Gupta wrote:


> > - pgtable-generic.c: Fold individual #ifdef for each helper into a top
> >   level #ifdef. Makes code more readable
> >
> > - Converted the stub helpers for !THP to BUILD_BUG() vs. runtime BUG()
> >
> > Signed-off-by: Vineet Gupta <vgupta@synopsys.com><mailto:vgupta@synopsy=
s.com>


>
> Sorry for sounding pushy - an Ack here will unblock me from dumping boat =
load of
> patches into linux-next via my tree !


I hope you've tested it with different .configs...

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com><mailto:kiril=
l.shutemov@linux.intel.com>

Atleast 2 configs with CONFIG_TRANSPARENT_HUGEPAGE on and off - for ARC !

I can test some more if u point me to.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

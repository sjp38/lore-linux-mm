Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id CA7C66B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 08:16:03 -0400 (EDT)
Received: by lagg8 with SMTP id g8so37968332lag.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 05:16:03 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id dr2si17496635wid.108.2015.03.16.05.16.01
        for <linux-mm@kvack.org>;
        Mon, 16 Mar 2015 05:16:02 -0700 (PDT)
Date: Mon, 16 Mar 2015 14:15:59 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: trigger panic on bad page or PTE states if
 panic_on_oops
Message-ID: <20150316121559.GB20546@node.dhcp.inet.fi>
References: <1426495021-6408-1-git-send-email-borntraeger@de.ibm.com>
 <20150316110033.GA20546@node.dhcp.inet.fi>
 <5506BAB6.3080104@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5506BAB6.3080104@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 16, 2015 at 12:12:54PM +0100, Christian Borntraeger wrote:
> Am 16.03.2015 um 12:00 schrieb Kirill A. Shutemov:
> > On Mon, Mar 16, 2015 at 09:37:01AM +0100, Christian Borntraeger wrote:
> >> while debugging a memory management problem it helped a lot to
> >> get a system dump as early as possible for bad page states.
> >>
> >> Lets assume that if panic_on_oops is set then the system should
> >> not continue with broken mm data structures.
> > 
> > bed_pte is not an oops.
> 
> I know that this is not an oops, but semantically it is like one.  I certainly
> want to a way to hard stop the system if something like that happens.
> 
> Would something like panic_on_mm_error be better?

Or panic_on_taint=<mask> where <mask> is bit-mask of TAINT_* values.

The problem is that TAINT_* will effectevely become part of kernel ABI
and I'm not sure it's good idea.

Oopsing on any taint will have limited usefulness, I think.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

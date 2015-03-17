Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1CD6B0032
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 15:40:58 -0400 (EDT)
Received: by wgbcc7 with SMTP id cc7so17129326wgb.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 12:40:57 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id fj2si4807174wib.112.2015.03.17.12.40.56
        for <linux-mm@kvack.org>;
        Tue, 17 Mar 2015 12:40:56 -0700 (PDT)
Date: Tue, 17 Mar 2015 21:40:53 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: trigger panic on bad page or PTE states if
 panic_on_oops
Message-ID: <20150317194053.GA27910@node.dhcp.inet.fi>
References: <1426495021-6408-1-git-send-email-borntraeger@de.ibm.com>
 <20150316110033.GA20546@node.dhcp.inet.fi>
 <5506BAB6.3080104@de.ibm.com>
 <20150316121559.GB20546@node.dhcp.inet.fi>
 <55086217.6060802@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55086217.6060802@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 17, 2015 at 08:19:19PM +0300, Konstantin Khlebnikov wrote:
> On 16.03.2015 15:15, Kirill A. Shutemov wrote:
> >On Mon, Mar 16, 2015 at 12:12:54PM +0100, Christian Borntraeger wrote:
> >>Am 16.03.2015 um 12:00 schrieb Kirill A. Shutemov:
> >>>On Mon, Mar 16, 2015 at 09:37:01AM +0100, Christian Borntraeger wrote:
> >>>>while debugging a memory management problem it helped a lot to
> >>>>get a system dump as early as possible for bad page states.
> >>>>
> >>>>Lets assume that if panic_on_oops is set then the system should
> >>>>not continue with broken mm data structures.
> >>>
> >>>bed_pte is not an oops.
> >>
> >>I know that this is not an oops, but semantically it is like one.  I certainly
> >>want to a way to hard stop the system if something like that happens.
> >>
> >>Would something like panic_on_mm_error be better?
> >
> >Or panic_on_taint=<mask> where <mask> is bit-mask of TAINT_* values.
> >
> >The problem is that TAINT_* will effectevely become part of kernel ABI
> >and I'm not sure it's good idea.
> 
> Taint bits have associated letters: for example panic_on_taint=OP
> panic on out-of-tree or propriate =)

Works for me.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

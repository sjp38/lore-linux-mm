Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id D0E46280011
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 16:33:56 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id ex7so2285996wid.14
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 13:33:56 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id gf8si84387wib.72.2014.10.31.13.33.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 13:33:54 -0700 (PDT)
Date: Fri, 31 Oct 2014 21:33:44 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 09/12] x86, mpx: decode MPX instruction to get bound
 violation information
In-Reply-To: <5453EE0E.8060200@intel.com>
Message-ID: <alpine.DEB.2.11.1410312133120.5308@nanos>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-10-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241408360.5308@nanos> <9E0BE1322F2F2246BD820DA9FC397ADE0180ED16@shsmsx102.ccr.corp.intel.com>
 <alpine.DEB.2.11.1410272135420.5308@nanos> <5453EE0E.8060200@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Ren, Qiaowei" <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>

On Fri, 31 Oct 2014, Dave Hansen wrote:

> On 10/27/2014 01:36 PM, Thomas Gleixner wrote:
> > You're repeating yourself. Care to read the discussion about this from
> > the last round of review again?
> 
> OK, so here's a rewritten decoder.  I think it's a lot more robust and
> probably fixes a bug or two.  This ends up saving ~70 lines of code out
> of ~300 or so for the old patch.
> 
> I'll include this in the next series, but I'm posting it early and often
> to make sure I'm on the right track.

Had a short glance. This looks really very well done!

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

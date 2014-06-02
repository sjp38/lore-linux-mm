Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 047EA6B0071
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 17:53:40 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so3864182pdi.27
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 14:53:40 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id bh2si17337574pbb.204.2014.06.02.14.53.39
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 14:53:40 -0700 (PDT)
Message-ID: <538CF25E.8070905@sr71.net>
Date: Mon, 02 Jun 2014 14:53:34 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] mm: pagewalk: huge page cleanups and VMA passing
References: <20140602213644.925A26D0@viggo.jf.intel.com> <1401745925-l651h3s9@n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1401745925-l651h3s9@n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 06/02/2014 02:52 PM, Naoya Horiguchi wrote:
> What version is this patchset based on?
> Recently I comprehensively rewrote page table walker (from the same motivation
> as yours) and the patchset is now in linux-mm. I guess most of your patchset
> (I've not read them yet) conflict with this patchset.
> So could you take a look on it?

It's on top of a version of Linus's from the last week.  I'll take a
look at how it sits on top of -mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

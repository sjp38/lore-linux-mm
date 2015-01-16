Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 944016B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 11:32:38 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id n3so3568489wiv.1
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 08:32:38 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id jx7si4993386wid.54.2015.01.16.08.32.36
        for <linux-mm@kvack.org>;
        Fri, 16 Jan 2015 08:32:36 -0800 (PST)
Date: Fri, 16 Jan 2015 18:32:17 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH -mm v7 00/13] pagewalk: improve vma handling, apply to
 new users
Message-ID: <20150116163217.GA509@node.dhcp.inet.fi>
References: <1415343692-6314-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415343692-6314-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, Jerome Marchand <jmarchan@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Nov 07, 2014 at 07:01:51AM +0000, Naoya Horiguchi wrote:
> This series is ver.7 of page table walker patchset.
> 
> I apologize about my long delay since previous version (I have moved to
> Japan last month and no machine access for a while.)
> I just rebased this onto mmotm-2014-11-05-16-01. I had some conflicts but
> the resolution was not hard.
> Trinity showed no bug at least in my environment.

Andrew, any chance you'll find time for the patchset?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

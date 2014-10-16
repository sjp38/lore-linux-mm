Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3236B0038
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 10:51:22 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id em10so4986216wid.1
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 07:51:21 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.226])
        by mx.google.com with ESMTP id ck2si2587013wib.24.2014.10.16.07.51.20
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 07:51:20 -0700 (PDT)
Date: Thu, 16 Oct 2014 17:51:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH -mm v6 00/13] pagewalk: improve vma handling, apply to
 new users
Message-ID: <20141016145106.GA22351@node.dhcp.inet.fi>
References: <1406920849-25908-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406920849-25908-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Jerome Marchand <jmarchan@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Aug 01, 2014 at 03:20:36PM -0400, Naoya Horiguchi wrote:
> This series is ver.6 of page table walker patchset.
> I just rebased this onto mmotm-2014-07-30-15-57 with no major change.
> Trinity shows no bug at least in my environment.

Andrew, is there any reason why the patchset is not yet applied?
I have some code on top of the patchset and it would be easier for me if
the patchset get to -mm.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

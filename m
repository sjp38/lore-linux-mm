Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 46B596B0038
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 15:23:18 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id m8so3427904obr.7
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 12:23:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x80si23450531oix.117.2014.10.16.12.23.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:23:17 -0700 (PDT)
Date: Thu, 16 Oct 2014 12:23:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v6 00/13] pagewalk: improve vma handling, apply to
 new users
Message-Id: <20141016122315.6e1b300596f74b49b8a5e36f@linux-foundation.org>
In-Reply-To: <20141016145106.GA22351@node.dhcp.inet.fi>
References: <1406920849-25908-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20141016145106.GA22351@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Jerome Marchand <jmarchan@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, 16 Oct 2014 17:51:06 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Fri, Aug 01, 2014 at 03:20:36PM -0400, Naoya Horiguchi wrote:
> > This series is ver.6 of page table walker patchset.
> > I just rebased this onto mmotm-2014-07-30-15-57 with no major change.
> > Trinity shows no bug at least in my environment.
> 
> Andrew, is there any reason why the patchset is not yet applied?

Not really, just timing.  The v2 series was a bit of a disaster so I'd
want to give a new series quiet a long testing period to get it shaken
down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

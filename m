Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id DE3826B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 16:38:23 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id n8so17334986qaq.6
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 13:38:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a18si7692573qai.69.2015.01.16.13.38.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jan 2015 13:38:22 -0800 (PST)
Date: Fri, 16 Jan 2015 13:38:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v7 00/13] pagewalk: improve vma handling, apply to
 new users
Message-Id: <20150116133820.ab5754f94201697fae3cefcc@linux-foundation.org>
In-Reply-To: <20150116163217.GA509@node.dhcp.inet.fi>
References: <1415343692-6314-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20150116163217.GA509@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, Jerome Marchand <jmarchan@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, 16 Jan 2015 18:32:17 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Fri, Nov 07, 2014 at 07:01:51AM +0000, Naoya Horiguchi wrote:
> > This series is ver.7 of page table walker patchset.
> > 
> > I apologize about my long delay since previous version (I have moved to
> > Japan last month and no machine access for a while.)
> > I just rebased this onto mmotm-2014-11-05-16-01. I had some conflicts but
> > the resolution was not hard.
> > Trinity showed no bug at least in my environment.
> 
> Andrew, any chance you'll find time for the patchset?
> 

That was 2+ months ago - the patches have decayed somewhat.  I'm only
seeing a few rejects so I'll have a play with them, see how it all
looks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26A1C6B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:42:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y128so5190382pfg.5
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 02:42:29 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id y9si401684plt.235.2017.10.20.02.42.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 02:42:27 -0700 (PDT)
Date: Fri, 20 Oct 2017 12:41:52 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging
 for 4.15, Part 1
Message-ID: <20171020094152.skx5sh5ramq2a3vu@black.fi.intel.com>
References: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
 <20171003082754.no6ym45oirah53zp@node.shutemov.name>
 <20171017154241.f4zaxakfl7fcrdz5@node.shutemov.name>
 <20171020081853.lmnvaiydxhy5c63t@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171020081853.lmnvaiydxhy5c63t@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Oct 20, 2017 at 08:18:53AM +0000, Ingo Molnar wrote:
> 
> * Kirill A. Shutemov <kirill@shutemov.name> wrote:
> 
> > On Tue, Oct 03, 2017 at 11:27:54AM +0300, Kirill A. Shutemov wrote:
> > > On Fri, Sep 29, 2017 at 05:08:15PM +0300, Kirill A. Shutemov wrote:
> > > > The first bunch of patches that prepare kernel to boot-time switching
> > > > between paging modes.
> > > > 
> > > > Please review and consider applying.
> > > 
> > > Ping?
> > 
> > Ingo, is there anything I can do to get review easier for you?
> 
> Yeah, what is the conclusion on the sub-discussion of patch #2:
> 
>   [PATCH 2/6] mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
> 
> ... do we want to skip it entirely and use the other 5 patches?

Yes, please. MAX_PHYSMEM_BITS not variable yet in this part of the series.

And I will post some version the patch in the next part, if it will be
required.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

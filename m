Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E16286B0033
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 11:42:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s78so1061572wmd.14
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 08:42:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o30sor5128969eda.56.2017.10.17.08.42.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 08:42:44 -0700 (PDT)
Date: Tue, 17 Oct 2017 18:42:41 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging
 for 4.15, Part 1
Message-ID: <20171017154241.f4zaxakfl7fcrdz5@node.shutemov.name>
References: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
 <20171003082754.no6ym45oirah53zp@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003082754.no6ym45oirah53zp@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 03, 2017 at 11:27:54AM +0300, Kirill A. Shutemov wrote:
> On Fri, Sep 29, 2017 at 05:08:15PM +0300, Kirill A. Shutemov wrote:
> > The first bunch of patches that prepare kernel to boot-time switching
> > between paging modes.
> > 
> > Please review and consider applying.
> 
> Ping?

Ingo, is there anything I can do to get review easier for you?

I hoped to get boot-time switching code into v4.15...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

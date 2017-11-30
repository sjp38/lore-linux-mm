Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05A236B0253
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 02:32:07 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z12so3805020pgv.6
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 23:32:06 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f25si2602326pge.273.2017.11.29.23.32.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 23:32:05 -0800 (PST)
Date: Thu, 30 Nov 2017 10:31:31 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 0/4] x86: 5-level related changes into decompression
 code
Message-ID: <20171130073130.afualycggltkvl6s@black.fi.intel.com>
References: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
 <20171129154908.6y4st6xc7hbsey2v@pd.tnic>
 <20171129161349.d7ksuhwhdamloty6@node.shutemov.name>
 <alpine.DEB.2.20.1711291740050.1825@nanos>
 <20171129170831.2iqpop2u534mgrbc@node.shutemov.name>
 <20171129174851.jk2ai37uumxve6sg@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129174851.jk2ai37uumxve6sg@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 29, 2017 at 05:48:51PM +0000, Borislav Petkov wrote:
> On Wed, Nov 29, 2017 at 08:08:31PM +0300, Kirill A. Shutemov wrote:
> > We're really early in the boot -- startup_64 in decompression code -- and
> > I don't know a way print a message there. Is there a way?
> > 
> > no_longmode handled by just hanging the machine. Is it enough for no_la57
> > case too?
> 
> Patch pls.

The patch below on top of patch 2/4 from this patch would do the trick.

Please give it a shot.

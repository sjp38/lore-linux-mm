Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 848496B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:30:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s63so41617765wme.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:30:47 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id y10si24489712wmb.17.2016.04.27.07.30.46
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 07:30:46 -0700 (PDT)
Date: Wed, 27 Apr 2016 16:30:45 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH v1 00/18] x86: Secure Memory Encryption (AMD)
Message-ID: <20160427143045.GA4718@amd>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160322130058.GA16528@xo-6d-61-c0.localdomain>
 <20160427140520.GG21011@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160427140520.GG21011@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed 2016-04-27 16:05:20, Borislav Petkov wrote:
> On Tue, Mar 22, 2016 at 02:00:58PM +0100, Pavel Machek wrote:
> > Why would I want SME on my system? My system seems to work without it.
> 
> Your system doesn't have it and SME is default off.

That does not answer the question. "Why would I want SME on my
system?".

And that answer should go to Documentation/.

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

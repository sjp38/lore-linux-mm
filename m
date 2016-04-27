Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 639E96B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 12:41:40 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id j8so42609919lfd.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 09:41:40 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id 14si10040623wmu.112.2016.04.27.09.41.39
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 09:41:39 -0700 (PDT)
Date: Wed, 27 Apr 2016 18:41:37 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH v1 02/18] x86: Secure Memory Encryption (SME) build
 enablement
Message-ID: <20160427164137.GA11779@amd>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225614.13567.47487.stgit@tlendack-t1.amdoffice.net>
 <20160322130150.GB16528@xo-6d-61-c0.localdomain>
 <5720D810.9060602@amd.com>
 <20160427153010.GA7861@amd>
 <20160427154140.GK21011@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160427154140.GK21011@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed 2016-04-27 17:41:40, Borislav Petkov wrote:
> On Wed, Apr 27, 2016 at 05:30:10PM +0200, Pavel Machek wrote:
> > Doing it early will break bisect, right?
> 
> How exactly? Please do tell.

Hey look, SME slowed down 30% since being initially merged into
kernel!
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

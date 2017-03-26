Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 416CF6B0337
	for <linux-mm@kvack.org>; Sun, 26 Mar 2017 06:18:11 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id l43so16920111wre.4
        for <linux-mm@kvack.org>; Sun, 26 Mar 2017 03:18:11 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id h7si10171469wma.43.2017.03.26.03.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Mar 2017 03:18:09 -0700 (PDT)
Message-ID: <1490523018.5920.3.camel@gmx.de>
Subject: Re: Splat during resume
From: Mike Galbraith <efault@gmx.de>
Date: Sun, 26 Mar 2017 12:10:18 +0200
In-Reply-To: <20170326084149.pisqkhngxjd65u6g@pd.tnic>
References: <20170325185855.4itsyevunczus7sc@pd.tnic>
	 <20170325214615.eqgmkwbkyldt7wwl@pd.tnic> <1490516743.17559.7.camel@gmx.de>
	 <20170326084149.pisqkhngxjd65u6g@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86-ml <x86@kernel.org>

On Sun, 2017-03-26 at 10:41 +0200, Borislav Petkov wrote:

> Btw, try the 6 patches here: 
> https://marc.info/?l=linux-mm&m=148977696117208&w=2
> ontop of tip. Should fix your vaporite too.

Yeah, silicon is still happy, vaporite boots gripe free.  Trying to
hibernate vaporite was a bad idea, but is unrelated to this thread.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

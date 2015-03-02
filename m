Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id F35216B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 10:52:10 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id uz6so31944821obc.9
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 07:52:10 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id jf9si137948oec.40.2015.03.02.07.52.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 07:52:09 -0800 (PST)
Message-ID: <1425311491.17007.165.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 0/7] Kernel huge I/O mapping support
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 02 Mar 2015 08:51:31 -0700
In-Reply-To: <20150224080927.GB19069@gmail.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
	 <20150223122224.c55554325cc4dadeca067234@linux-foundation.org>
	 <20150224080927.GB19069@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com

On Tue, 2015-02-24 at 09:09 +0100, Ingo Molnar wrote:
> * Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > <reads the code>
> > 
> > Oh.  We don't do any checking at all.  We're just telling 
> > userspace programmers "don't do that".  hrm.  What are 
> > your thoughts on adding the overlap checks to the kernel?
> 
> I have requested such sanity checking in previous review as 
> well, it has to be made fool-proof for this optimization to 
> be usable.
> 
> Another alternative would be to make this not a transparent 
> optimization, but a separate API: ioremap_hugepage() or so.
> 
> The devices and drivers dealing with GBs of remapped pages 
> is still relatively low, so they could make explicit use of 
> the API and opt in to it.
> 
> What I was arguing against was to make it a CONFIG_ option: 
> that achieves very little in practice, such APIs should be 
> uniformly available.

I was able to come up with simple changes that fall back to 4KB mappings
when a target range is covered by MTRRs.  So, with the changes, it is
now safe to enable huge page mappings to ioremap() transparently without
such restriction.  I will post updated patchset hopefully soon.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

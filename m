Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41F2B6B02EE
	for <linux-mm@kvack.org>; Thu, 11 May 2017 23:36:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e131so34367441pfh.7
        for <linux-mm@kvack.org>; Thu, 11 May 2017 20:36:49 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b4si1935313plb.115.2017.05.11.20.36.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 May 2017 20:36:48 -0700 (PDT)
Received: from mail-vk0-f52.google.com (mail-vk0-f52.google.com [209.85.213.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3A3C72399B
	for <linux-mm@kvack.org>; Fri, 12 May 2017 03:36:48 +0000 (UTC)
Received: by mail-vk0-f52.google.com with SMTP id h16so11696939vkd.2
        for <linux-mm@kvack.org>; Thu, 11 May 2017 20:36:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170511071348.jhgzdgi7blhgenqj@gmail.com>
References: <cover.1494160201.git.luto@kernel.org> <1a124281c99741606f1789140f9805beebb119da.1494160201.git.luto@kernel.org>
 <alpine.DEB.2.20.1705092236290.2295@nanos> <20170510055727.g6wojjiis36a6nvm@gmail.com>
 <alpine.DEB.2.20.1705101017590.1979@nanos> <20170510082425.5ks5okbjne7xgjtv@gmail.com>
 <CALCETrV-c8n92v040HVw=6OdnNrLvN7ZAcAJ45Xs4wx-7H5r=g@mail.gmail.com> <20170511071348.jhgzdgi7blhgenqj@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 11 May 2017 20:36:26 -0700
Message-ID: <CALCETrXTP_eA=ZEg5Gf7unZHhhbSedcZf7tiCApFR9axd6Q+vA@mail.gmail.com>
Subject: Re: [RFC 09/10] x86/mm: Rework lazy TLB to track the actual loaded mm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Thu, May 11, 2017 at 12:13 AM, Ingo Molnar <mingo@kernel.org> wrote:
> My personal favorite is double underscores prefix, i.e. 'void *__mm', which would
> clearly signal that this is something special. But this does not appear to have
> been picked up overly widely:

Nice bikeshed!  I'll use it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

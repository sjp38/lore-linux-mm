Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7CB776B0031
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 03:53:41 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id n15so494795wiw.10
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 00:53:40 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id ap2si8627268wjc.53.2014.06.26.00.53.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jun 2014 00:53:40 -0700 (PDT)
Date: Thu, 26 Jun 2014 09:53:34 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/6] RCU get_user_pages_fast and __get_user_pages_fast
Message-ID: <20140626075334.GA12054@laptop.lan>
References: <1403710824-24340-1-git-send-email-steve.capper@linaro.org>
 <20140625134235.4f32768faa1a4380a62458ff@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140625134235.4f32768faa1a4380a62458ff@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steve Capper <steve.capper@linaro.org>, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org, will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, anders.roxell@linaro.org

On Wed, Jun 25, 2014 at 01:42:35PM -0700, Andrew Morton wrote:
> On Wed, 25 Jun 2014 16:40:18 +0100 Steve Capper <steve.capper@linaro.org> wrote:
> 
> > This series implements general forms of get_user_pages_fast and
> > __get_user_pages_fast and activates them for arm and arm64.
> 
> Why not x86?
> 
> I think I might have already asked this.  If so, it's your fault for
> not updating the changelog ;)

Because x86 doesn't do RCU freed page tables :-) Also because i386 PAE
has magic (although one might expect ARM PAE -- or whatever they called
it -- to need similar magic).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

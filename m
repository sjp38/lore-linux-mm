Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id AC24A6B0035
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 11:50:37 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so12088132pad.8
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 08:50:37 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id oa10si863117pbb.112.2014.07.22.08.50.36
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 08:50:36 -0700 (PDT)
Date: Tue, 22 Jul 2014 16:50:12 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv4 2/5] lib/genalloc.c: Add genpool range check function
Message-ID: <20140722155012.GK2219@arm.com>
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org>
 <1404324218-4743-3-git-send-email-lauraa@codeaurora.org>
 <CAOesGMiKBNDmJhiY-yK0uZmG-MnK82=ffNGxqasLKozqgpQQpw@mail.gmail.com>
 <53CD6F28.3080203@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53CD6F28.3080203@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Olof Johansson <olof@lixom.net>, Will Deacon <Will.Deacon@arm.com>, David Riley <davidriley@chromium.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jul 21, 2014 at 08:51:04PM +0100, Laura Abbott wrote:
> On 7/9/2014 3:33 PM, Olof Johansson wrote:
> > On Wed, Jul 2, 2014 at 11:03 AM, Laura Abbott <lauraa@codeaurora.org> wrote:
> >>
> >> After allocating an address from a particular genpool,
> >> there is no good way to verify if that address actually
> >> belongs to a genpool. Introduce addr_in_gen_pool which
> >> will return if an address plus size falls completely
> >> within the genpool range.
> >>
> >> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> > 
> > Reviewed-by: Olof Johansson <olof@lixom.net>
> > 
> > What's the merge path for this code? Part of the arm64 code that needs
> > it, I presume?
> 
> My plan was to have the entire series go through the arm64 tree unless
> someone has a better idea.

It's fine by me. But since it touches core arch/arm code, I would like
to see an Ack from Russell.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

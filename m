Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D438E6B03A2
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 12:23:30 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id f98so4256908iod.18
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 09:23:30 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id s141si2343944itb.110.2017.04.11.09.23.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 09:23:30 -0700 (PDT)
Date: Tue, 11 Apr 2017 11:23:28 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Add additional consistency check
In-Reply-To: <CAGXu5jK1j3UWUakakFw=EfVwg+Rnovzst52+uZJYesLqLY+n5A@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1704111122550.25069@east.gentwo.org>
References: <20170404113022.GC15490@dhcp22.suse.cz> <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org> <20170404151600.GN15132@dhcp22.suse.cz> <alpine.DEB.2.20.1704041412050.27424@east.gentwo.org> <20170404194220.GT15132@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041457030.28085@east.gentwo.org> <20170404201334.GV15132@dhcp22.suse.cz> <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com> <20170411134618.GN6729@dhcp22.suse.cz> <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com>
 <20170411141956.GP6729@dhcp22.suse.cz> <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org> <CAGXu5jK1j3UWUakakFw=EfVwg+Rnovzst52+uZJYesLqLY+n5A@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 11 Apr 2017, Kees Cook wrote:

> It seems that enabling the debug checks comes with a non-trivial
> performance impact. I'd like to see consistency checks by default so
> we can handle intentional heap corruption attacks better. This check
> isn't expensive...

Its in a very hot code and frequently used code path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

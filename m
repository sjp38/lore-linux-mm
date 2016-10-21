Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4696B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 09:47:21 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x11so90693030qka.5
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 06:47:21 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id a65si1945459qkc.140.2016.10.21.06.47.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Oct 2016 06:47:08 -0700 (PDT)
Date: Fri, 21 Oct 2016 08:44:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Rewording language in mbind(2) to "threads" not "processes"
In-Reply-To: <67165fae-b965-eb34-ecf5-4247acaecee1@gmail.com>
Message-ID: <alpine.DEB.2.20.1610210844120.24973@east.gentwo.org>
References: <f3c4ca9d-a880-5244-e06e-db4725e4d945@gmail.com> <alpine.DEB.2.20.1610131314020.3176@east.gentwo.org> <CAKgNAkiMo-AMZ2PUm3A8NqfiNa+GOnRFn4NrFwjRJa8Z7xNsPw@mail.gmail.com> <67165fae-b965-eb34-ecf5-4247acaecee1@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, mhocko@kernel.org, mgorman@techsingularity.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, linux-man <linux-man@vger.kernel.org>, Brice Goglin <Brice.Goglin@inria.fr>

On Fri, 21 Oct 2016, Michael Kerrisk (man-pages) wrote:

> Did you have any thoughts on my follow-on question below?

There was only one AFAICT?

> > Thanks. So, are all the other cases where I changed "process" to
> > "thread" okay then?

>From what I see yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

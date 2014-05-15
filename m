Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 77DAD6B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 00:15:09 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id va2so598791obc.9
        for <linux-mm@kvack.org>; Wed, 14 May 2014 21:15:09 -0700 (PDT)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id rk8si2321121oeb.165.2014.05.14.21.15.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 21:15:08 -0700 (PDT)
Received: by mail-ob0-f172.google.com with SMTP id wp18so587630obc.17
        for <linux-mm@kvack.org>; Wed, 14 May 2014 21:15:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140514203859.8c82aa3a.akpm@linux-foundation.org>
References: <c8b0a9a0b8d011a8b273cbb2de88d37190ed2751.1400111179.git.luto@amacapital.net>
	<CAJd=RBC1E9x-zU-zJbNP+zbPgb=nhi39TqrxqpcGdi=OR9duXg@mail.gmail.com>
	<20140514203859.8c82aa3a.akpm@linux-foundation.org>
Date: Thu, 15 May 2014 12:15:08 +0800
Message-ID: <CAJd=RBCc15D-thT8Fzw+5bb=1vYrjMh2JaDpDLYzd1kJosLd-w@mail.gmail.com>
Subject: Re: [PATCH v2 -next] x86,vdso: Fix an OOPS accessing the hpet mapping
 w/o an hpet
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, x86@kernel.org, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Stefani Seibold <stefani@seibold.net>

On Thu, May 15, 2014 at 11:38 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> We could easily change the interface so that pages==NULL means "no
> pages" but that isn't the way it works at present.
>
Yeah, thanks /Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

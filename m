Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id A9E4C6B00BA
	for <linux-mm@kvack.org>; Mon, 18 May 2015 09:29:08 -0400 (EDT)
Received: by qkgw4 with SMTP id w4so68686660qkg.3
        for <linux-mm@kvack.org>; Mon, 18 May 2015 06:29:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o32si10224588qko.57.2015.05.18.06.29.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 06:29:08 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CALq1K=J4iRqD5qiSr2S7m+jgr63K7=e1PmA-pX1s4MEDimsLbw@mail.gmail.com>
References: <CALq1K=J4iRqD5qiSr2S7m+jgr63K7=e1PmA-pX1s4MEDimsLbw@mail.gmail.com> <CALq1K=KSkPB9LY__rh04ic_rv2H0rGCLNfeKoY-+U2=EF32sBg@mail.gmail.com> <7254.1431945085@warthog.procyon.org.uk>
Subject: Re: [RFC] Refactor kenter/kleave/kdebug macros
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <23798.1431955741.1@warthog.procyon.org.uk>
Content-Transfer-Encoding: quoted-printable
Date: Mon, 18 May 2015 14:29:01 +0100
Message-ID: <23799.1431955741@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@leon.nu>
Cc: dhowells@redhat.com, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-cachefs <linux-cachefs@redhat.com>, linux-afs <linux-afs@lists.infradead.org>

Leon Romanovsky <leon@leon.nu> wrote:

> Blind conversion to pr_debug will blow the code because it will be alway=
s
> compiled in.

No, it won't.

> Additionally, It looks like the output of these macros can be viewed by =
ftrace
> mechanism.

*blink* It can?

> Maybe we should delete them from mm/nommu.c as was pointed by Joe?

Why?

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

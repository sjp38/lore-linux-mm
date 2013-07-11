Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id CDB136B0033
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 03:04:34 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hj3so12235138wib.4
        for <linux-mm@kvack.org>; Thu, 11 Jul 2013 00:04:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1373526037-9134-1-git-send-email-gg.kaspersky@gmail.com>
References: <1373526037-9134-1-git-send-email-gg.kaspersky@gmail.com>
Date: Thu, 11 Jul 2013 10:04:33 +0300
Message-ID: <CAOJsxLH3inzJ6xdfh9WdJ=Jx+DT32kbsVpd6r355O4QnWJu-fg@mail.gmail.com>
Subject: Re: [PATCH] madvise: fix checkpatch errors
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Cernov <gg.kaspersky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, linux@rasmusvillemoes.dk, shli@fusionio.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 11, 2013 at 10:00 AM, Vladimir Cernov
<gg.kaspersky@gmail.com> wrote:
> This fixes following errors:
>         - ERROR: "(foo*)" should be "(foo *)"
>         - ERROR: "foo ** bar" should be "foo **bar"
>
> Signed-off-by: Vladimir Cernov <gg.kaspersky@gmail.com>

Reviewed-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

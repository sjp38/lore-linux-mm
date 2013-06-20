Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 62F906B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 15:22:49 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id n10so8374069oag.28
        for <linux-mm@kvack.org>; Thu, 20 Jun 2013 12:22:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1371753290.2146.35.camel@joe-AO722>
References: <1371753290.2146.35.camel@joe-AO722>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 20 Jun 2013 12:22:28 -0700
Message-ID: <CAHGf_=qo09Qxja8v2ORShi3kvv4z1Zk-nGPLR9k0UA3Car1xLA@mail.gmail.com>
Subject: Re: [PATCH] mm: remove unused VM_<READfoo> macros and expand other in-place
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 20, 2013 at 11:34 AM, Joe Perches <joe@perches.com> wrote:
> These VM_<READfoo> macros aren't used very often and
> three of them aren't used at all.
>
> Expand the ones that are used in-place, and remove
> all the now unused #define VM_<foo> macros.
>
> VM_READHINTMASK, VM_NormalReadHint and VM_ClearReadHint
> were added just before 2.4 and appears have never been used.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> Found by looking for CamelCase variable name exceptions

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9E30A8D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 02:24:32 -0400 (EDT)
Received: by gyg10 with SMTP id 10so704104gyg.14
        for <linux-mm@kvack.org>; Tue, 15 Mar 2011 23:24:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1300244054.3128.417.camel@calx>
References: <20110316022804.27679.qmail@science.horizon.com>
	<1300244054.3128.417.camel@calx>
Date: Wed, 16 Mar 2011 08:24:30 +0200
Message-ID: <AANLkTimfieJ4DxSrDiA_EEqe+V3BzsFygQ=GgQBTGx0u@mail.gmail.com>
Subject: Re: [PATCH 1/8] drivers/random: Cache align ip_random better
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: George Spelvin <linux@horizon.com>, penberg@cs.helsinki.fi, herbert@gondor.apana.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 16, 2011 at 4:54 AM, Matt Mackall <mpm@selenic.com> wrote:
> On Sun, 2011-03-13 at 20:20 -0400, George Spelvin wrote:
>> Cache aligning the secret[] buffer makes copying from it infinitesimally
>> more efficient.
>
> Acked-by: Matt Mackall <mpm@selenic.com>

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

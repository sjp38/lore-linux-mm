Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id D2D1A6B005D
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 08:12:57 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id dq12so1994435wgb.26
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 05:12:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121004102013.GA23284@lizard>
References: <20121004102013.GA23284@lizard>
Date: Fri, 12 Oct 2012 15:12:55 +0300
Message-ID: <CAOJsxLF8qc-_YWiUaNz2FPKF2pds8J2P=NbrBZnD2eHB=s3jzA@mail.gmail.com>
Subject: Re: [PATCH 0/3] A few cleanups and refactorings, sync w/ upstream
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

Hi Anton,

On Thu, Oct 4, 2012 at 1:20 PM, Anton Vorontsov
<anton.vorontsov@linaro.org> wrote:
> Hello Pekka,
>
> Just a few updates to vmevents:
>
> - Some cleanups and refactorings -- needed for easier integration of
>   'memory pressure' work;
> - Forward to newer Linus' tree, fix conflicts.

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

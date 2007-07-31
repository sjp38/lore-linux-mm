Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id l6V5Aoo5014899
	for <linux-mm@kvack.org>; Tue, 31 Jul 2007 06:10:51 +0100
Received: from py-out-1112.google.com (pyia25.prod.google.com [10.34.253.25])
	by zps77.corp.google.com with ESMTP id l6V5A1lm002320
	for <linux-mm@kvack.org>; Mon, 30 Jul 2007 22:10:43 -0700
Received: by py-out-1112.google.com with SMTP id a25so3165376pyi
        for <linux-mm@kvack.org>; Mon, 30 Jul 2007 22:10:43 -0700 (PDT)
Message-ID: <65dd6fd50707302210y5b79a70di58eb2d46f3958025@mail.gmail.com>
Date: Mon, 30 Jul 2007 22:10:43 -0700
From: "Ollie Wild" <aaw@google.com>
Subject: Re: [SPARC32] NULL pointer derefference
In-Reply-To: <Pine.LNX.4.61.0707300301340.32210@mtfhpc.demon.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.61.0707300301340.32210@mtfhpc.demon.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, wli@holomorphy.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On 7/29/07, Mark Fortescue <mark@mtfhpc.demon.co.uk> wrote:
> Hi All,
>
> Unfortunatly Sparc32 sun4c low level memory management apears to be
> incompatible with commit b6a2fea39318e43fee84fa7b0b90d68bed92d2ba
> mm: variable length argument support.

I feel like I ought to help out with this since it's my change which
broke things, but I don't have access to a Sparc32 box.  Does anyone
have a remotely rebootable machine I can use?

Ollie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

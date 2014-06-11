Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id BAE286B0168
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 13:38:59 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id y10so76604wgg.17
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 10:38:59 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id ys3si43071892wjc.16.2014.06.11.10.38.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 10:38:58 -0700 (PDT)
Received: by mail-wi0-f181.google.com with SMTP id n3so1587998wiv.14
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 10:38:57 -0700 (PDT)
Date: Wed, 11 Jun 2014 18:38:51 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: kmemleak: Unable to handle kernel paging request
Message-ID: <20140611173851.GA5556@MacBook-Pro.local>
References: <CAOJe8K3fy3XFxDdVc3y1hiMAqUCPmkUhECU7j5TT=E=gxwBqHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOJe8K3fy3XFxDdVc3y1hiMAqUCPmkUhECU7j5TT=E=gxwBqHg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denis Kirjanov <kda@linux-powerpc.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 11, 2014 at 04:13:07PM +0400, Denis Kirjanov wrote:
> I got a trace while running 3.15.0-08556-gdfb9454:
> 
> [  104.534026] Unable to handle kernel paging request for data at
> address 0xc00000007f000000

Were there any kmemleak messages prior to this, like "kmemleak
disabled"? There could be a race when kmemleak is disabled because of
some fatal (for kmemleak) error while the scanning is taking place
(which needs some more thinking to fix properly).

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 23D9C8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 16:07:35 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 202so5410845pgb.6
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:07:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g19si21698517pgj.358.2018.12.21.13.07.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Dec 2018 13:07:34 -0800 (PST)
Date: Fri, 21 Dec 2018 13:07:21 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 01/12] x86_64: memset_user()
Message-ID: <20181221210721.GK10600@bombadil.infradead.org>
References: <20181221181423.20455-1-igor.stoppa@huawei.com>
 <20181221181423.20455-2-igor.stoppa@huawei.com>
 <20181221182515.GF10600@bombadil.infradead.org>
 <20181221200546.GA8441@uranus>
 <20181221202946.GJ10600@bombadil.infradead.org>
 <20181221204616.GC8441@uranus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181221204616.GC8441@uranus>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Igor Stoppa <igor.stoppa@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 21, 2018 at 11:46:16PM +0300, Cyrill Gorcunov wrote:
> Cast to unsigned char is needed in any case. And as far as I remember
> we've been using this multiplication trick for a really long time
> in x86 land. I'm out of sources right now but it should be somewhere
> in assembly libs.

x86 isn't the only CPU.  Some CPUs have slow multiplies but fast shifts.
Also loading 0x0101010101010101 into a register may be inefficient on
some CPUs.

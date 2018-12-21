Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1C3B8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 15:46:19 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id t22-v6so2015283lji.14
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 12:46:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j188sor7438276lfj.72.2018.12.21.12.46.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 12:46:17 -0800 (PST)
Date: Fri, 21 Dec 2018 23:46:16 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 01/12] x86_64: memset_user()
Message-ID: <20181221204616.GC8441@uranus>
References: <20181221181423.20455-1-igor.stoppa@huawei.com>
 <20181221181423.20455-2-igor.stoppa@huawei.com>
 <20181221182515.GF10600@bombadil.infradead.org>
 <20181221200546.GA8441@uranus>
 <20181221202946.GJ10600@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181221202946.GJ10600@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Igor Stoppa <igor.stoppa@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 21, 2018 at 12:29:46PM -0800, Matthew Wilcox wrote:
> > > 
> > > That's inefficient.
> > > 
> > > 	pattern = (unsigned char)c;
> > > 	pattern |= pattern << 8;
> > > 	pattern |= pattern << 16;
> > > 	pattern |= pattern << 32;
> > 
> > Won't
> > 
> > 	pattern = 0x0101010101010101 * c;
> > 
> > do the same but faster?
> 
> Depends on your CPU.  Some yes, some no.
> 
> (Also you need to cast 'c' to unsigned char to avoid someone passing in
> 0x1234 and getting 0x4646464646464634 instead of 0x3434343434343434)

Cast to unsigned char is needed in any case. And as far as I remember
we've been using this multiplication trick for a really long time
in x86 land. I'm out of sources right now but it should be somewhere
in assembly libs.

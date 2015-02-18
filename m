Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 28A336B0074
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 05:46:45 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id bs8so40007256wib.0
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 02:46:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mb13si12677115wic.62.2015.02.18.02.46.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 02:46:43 -0800 (PST)
Date: Wed, 18 Feb 2015 11:46:38 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH v2] x86, kaslr: propagate base load address calculation
In-Reply-To: <20150218083248.GA3211@pd.tnic>
Message-ID: <alpine.LNX.2.00.1502181146180.28769@pobox.suse.cz>
References: <CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com> <alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz> <alpine.LNX.2.00.1502110010190.10719@pobox.suse.cz> <alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz> <20150217104443.GC9784@pd.tnic>
 <alpine.LNX.2.00.1502171319040.2279@pobox.suse.cz> <20150217123933.GC26165@pd.tnic> <CAGXu5jL7opSG92o5Gu2tT-NWTfiC7dNSMLynPZWb8uHzUoUqLg@mail.gmail.com> <20150217223105.GI26165@pd.tnic> <CAGXu5jKQDfhvr04OAxeFO+nhpnVgQ40444SvBPpCZkF4CVa28g@mail.gmail.com>
 <20150218083248.GA3211@pd.tnic>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Kees Cook <keescook@chromium.org>, "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Wed, 18 Feb 2015, Borislav Petkov wrote:

> > Acked-by: Kees Cook <keescook@chromium.org>
> 
> Thanks Kees, I'll fold it into Jiri's patch and forward.

Fine by me, thanks.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA2E6B03B5
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 17:32:27 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f64so1364697pfd.6
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 14:32:27 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d8sor490571pga.147.2018.01.03.14.32.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 14:32:25 -0800 (PST)
Date: Wed, 3 Jan 2018 14:32:22 -0800
From: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
Message-ID: <20180103223222.GA22901@trogon.sfo.coreos.systems>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com>
 <20180103084600.GA31648@trogon.sfo.coreos.systems>
 <20180103092016.GA23772@kroah.com>
 <20180103154833.fhkbwonz6zhm26ax@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180103154833.fhkbwonz6zhm26ax@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, Jan 03, 2018 at 04:48:33PM +0100, Ingo Molnar wrote:
> first please test the latest WIP.x86/pti branch which has a couple of fixes.

I'm still seeing the problem with that branch (3ffdeb1a02be, plus a couple
of local patches which shouldn't affect the resulting binary).

--Benjamin Gilbert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

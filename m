Received: by wa-out-1112.google.com with SMTP id m33so1385594wag.8
        for <linux-mm@kvack.org>; Thu, 10 Jan 2008 12:23:08 -0800 (PST)
Message-ID: <6934efce0801101223g6b022094qc201a82096994b4c@mail.gmail.com>
Date: Thu, 10 Jan 2008 12:23:08 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [rfc][patch 1/4] include: add callbacks to toggle reference counting for VM_MIXEDMAP pages
In-Reply-To: <4785D064.1040501@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071214133817.GB28555@wotan.suse.de>
	 <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de>
	 <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de>
	 <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com>
	 <1199891032.28689.9.camel@cotte.boeblingen.de.ibm.com>
	 <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com>
	 <6934efce0801091017t7f9041abs62904de3722cadc@mail.gmail.com>
	 <4785D064.1040501@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

> In fact, I consider pfn_valid() broken on arm if it returns
> false for a pfn that is perfectly valid for use in a pfnmap/mixedmap
> mapping.

Remember, my interest in creating VM_MIXEDMAP is in mapping Flash into
these pfnmap/mixedmap regions.  I don't think it's fair to let
pfn_valid() work for Flash pages, at least for now, because there are
many things you can't do with them that you can do with RAM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

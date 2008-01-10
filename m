Received: by nz-out-0506.google.com with SMTP id i11so534738nzh.26
        for <linux-mm@kvack.org>; Thu, 10 Jan 2008 12:01:19 -0800 (PST)
Message-ID: <6934efce0801101201t72e9b7c4ra88d6fda0f08b1b2@mail.gmail.com>
Date: Thu, 10 Jan 2008 12:01:18 -0800
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

> I think you're looking for
> pfn_has_struct_page_entry_for_it(), and that's different from the
> original meaning described above.

Yes.  That's what I'm looking for.

Carsten,

I think I get the problem now.  You've been saying over and over, I
just didn't hear it.  We are not using the same assumptions for what
VM_MIXEDMAP means.

Look's like today most architectures just use pfn_valid() to see if a
pfn is in a valid RAM segment.  The assumption used in
vm_normal_page() is that valid_RAM == has_page_struct.  That's fine by
me for VM_MIXEDMAP because I'm only assuming 2 states a page can be
in: (1) page struct RAM (2) pfn only Flash memory ioremap()'ed in.
You are wanting to add a third: (3) valid RAM, pfn only mapping with
the ability to add a page struct when needed.

Is this right?

> Jared, did you try this on arm?

No.  I'm not sure where we stand.  Shall I bother or do I wait for the
next patch?

> Did it work for you with my proposed
> callback implementation?

I'm sure I can make a callback work kind of like I proposed above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

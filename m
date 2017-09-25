Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id C25D86B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 15:41:58 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id 97so7601741uai.4
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 12:41:58 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id z29si2937242uah.122.2017.09.25.12.41.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 12:41:57 -0700 (PDT)
Date: Mon, 25 Sep 2017 14:41:31 -0500
From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] mm: fix RODATA_TEST failure "rodata_test: test data was not read only"
Message-ID: <20170925194130.GV8421@gate.crashing.org>
References: <20170921093729.1080368AC1@po15668-vm-win7.idsi0.si.c-s.fr> <CAGXu5jJ54+bCcXaPK1ExsxtTDPHNn1+1gywb3TDbe-SEtt1zuQ@mail.gmail.com> <20170925073721.GM8421@gate.crashing.org> <063D6719AE5E284EB5DD2968C1650D6DD007F58B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD007F58B@AcuExch.aculab.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>
Cc: Kees Cook <keescook@chromium.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jinbum Park <jinb.park7@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Mon, Sep 25, 2017 at 04:01:55PM +0000, David Laight wrote:
> From: Segher Boessenkool
> > The compiler puts this item in .sdata, for 32-bit.  There is no .srodata,
> > so if it wants to use a small data section, it must use .sdata .
> > 
> > Non-external, non-referenced symbols are not put in .sdata, that is the
> > difference you see with the "static".
> > 
> > I don't think there is a bug here.  If you think there is, please open
> > a GCC bug.
> 
> The .sxxx sections are for 'small' data that can be accessed (typically)
> using small offsets from a global register.
> This means that all sections must be adjacent in the image.
> So you can't really have readonly small data.
> 
> My guess is that the linker script is putting .srodata in with .sdata.

.srodata does not *exist* (in the ABI).


Segher

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

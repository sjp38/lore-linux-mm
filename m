Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A3CC06B0254
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 21:34:09 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id uo6so92221494pac.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 18:34:09 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id rp7si464035pab.99.2016.01.25.18.34.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 18:34:09 -0800 (PST)
Received: by mail-pa0-x232.google.com with SMTP id yy13so90213719pab.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 18:34:08 -0800 (PST)
Date: Mon, 25 Jan 2016 18:34:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] arm64: let set_memory_xx(addr, 0) succeed.
In-Reply-To: <56A66D28.1080204@redhat.com>
Message-ID: <alpine.DEB.2.10.1601251832420.10939@chino.kir.corp.google.com>
References: <1453561543-14756-1-git-send-email-mika.penttila@nextfour.com> <1453561543-14756-4-git-send-email-mika.penttila@nextfour.com> <56A66D28.1080204@redhat.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-1921802141-1453775647=:10939"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: mika.penttila@nextfour.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@arm.linux.org.uk, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-1921802141-1453775647=:10939
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Mon, 25 Jan 2016, Laura Abbott wrote:

> On 01/23/2016 07:05 AM, mika.penttila@nextfour.com wrote:
> > From: Mika PenttilA? <mika.penttila@nextfour.com>
> > 
> > This makes set_memory_xx() consistent with x86.
> > 
> > Signed-off-by: Mika PenttilA? mika.penttila@nextfour.com
> > 
> > ---
> >   arch/arm64/mm/pageattr.c | 3 +++
> >   1 file changed, 3 insertions(+)
> > 
> > diff --git a/arch/arm64/mm/pageattr.c b/arch/arm64/mm/pageattr.c
> > index 3571c73..52220dd 100644
> > --- a/arch/arm64/mm/pageattr.c
> > +++ b/arch/arm64/mm/pageattr.c
> > @@ -51,6 +51,9 @@ static int change_memory_common(unsigned long addr, int
> > numpages,
> >   		WARN_ON_ONCE(1);
> >   	}
> > 
> > +	if (!numpages)
> > +		return 0;
> > +
> >   	if (start < MODULES_VADDR || start >= MODULES_END)
> >   		return -EINVAL;
> > 
> > 
> 
> I think this is going to conflict with Ard's patch
> lkml.kernel.org/g/<1453125665-26627-1-git-send-email-ard.biesheuvel@linaro.org>
> 
> Can you rebase on top of that?
> 

Also, I think patch 2 and 3 can be folded together since the change is the 
same to both functions.

I think the changelog should be expanded to explain that 
charge_memory_common() with numpages == 0 should be a no-op.

When both of those are done, and it's rebased as requested, feel free to 
add my:

	Acked-by: David Rientjes <rientjes@google.com>
--397176738-1921802141-1453775647=:10939--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

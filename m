Received: by uproxy.gmail.com with SMTP id h2so257859ugf
        for <linux-mm@kvack.org>; Fri, 24 Mar 2006 06:54:17 -0800 (PST)
Message-ID: <bc56f2f0603240654n4b978cb0p@mail.gmail.com>
Date: Fri, 24 Mar 2006 09:54:17 -0500
From: "Stone Wang" <pwstone@gmail.com>
Subject: Re: [PATCH][0/8] (Targeting 2.6.17) Posix memory locking and balanced mlock-LRU semantic
In-Reply-To: <p73bqvv6ha9.fsf@verdi.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <bc56f2f0603200535s2b801775m@mail.gmail.com>
	 <p73bqvv6ha9.fsf@verdi.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am preparing patch for 2.6.16, replace the name "wired" with "pinned".

Potentially, the list could be used for more purposes, than just mlocked pages.

Shaoping Wang

24 Mar 2006 15:36:46 +0100, Andi Kleen <ak@suse.de>:
> "Stone Wang" <pwstone@gmail.com> writes:
> >    mlocked areas.
> > 2. More consistent LRU semantics in Memory Management.
> >    Mlocked pages is placed on a separate LRU list: Wired List.
>
> If it's mlocked why don't you just called it Mlocked list?
> Strange jargon makes the patch cooler? Also in meminfo
>
> -Andi
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

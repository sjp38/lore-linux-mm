Received: by qb-out-0506.google.com with SMTP id e21so6833962qba.0
        for <linux-mm@kvack.org>; Sat, 09 Feb 2008 08:46:11 -0800 (PST)
Message-ID: <2f11576a0802090846t7655e988pb1b712696cad1098@mail.gmail.com>
Date: Sun, 10 Feb 2008 01:46:06 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [sample] mem_notify v6: usage example
In-Reply-To: <CE520A17-98F2-4A08-82AB-C3D5061616A1@jonmasters.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <2f11576a0802090755n123c9b7dh26e0af6a2fef28af@mail.gmail.com>
	 <CE520A17-98F2-4A08-82AB-C3D5061616A1@jonmasters.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Masters <jonathan@jonmasters.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Al Boldi <a1426z@gawab.com>, Zan Lynx <zlynx@acm.org>
List-ID: <linux-mm.kvack.org>

Hi Jon

> This really needs to be triggered via a generic kernel event in the
> final version - I picture glibc having a reservation API and having
> generic support for freeing such reservations.

to be honest, I doubt idea of generic reservation framework.

end up, we hope drop the application cache, not also dataless memory.
but, automatically drop mechanism only able to drop dataless memory.

and, many application have own memory management subsystem.
I afraid to nobody use too complex framework.

What do you think it?
I hope see your API. please post it.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

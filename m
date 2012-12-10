Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 9EB1D6B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 16:47:46 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id dq11so1717959wgb.26
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 13:47:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121210214256.GB23484@liondog.tnic>
References: <50C32D32.6040800@iskon.hr> <50C3AF80.8040700@iskon.hr>
 <alpine.LFD.2.02.1212081651270.4593@air.linux-foundation.org>
 <20121210110337.GH1009@suse.de> <20121210163904.GA22101@cmpxchg.org>
 <20121210180141.GK1009@suse.de> <50C62AE6.3030000@iskon.hr>
 <CA+55aFwNE2y5t2uP3esCnHsaNo0NTDnGvzN6KF0qTw_y+QbtFA@mail.gmail.com>
 <50C6477A.4090005@iskon.hr> <CA+55aFx9XSjtMZNuveyKrxL0LUjmZpFvJ7vzkjaKgQZLCs9QCg@mail.gmail.com>
 <20121210214256.GB23484@liondog.tnic>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 10 Dec 2012 13:47:23 -0800
Message-ID: <CA+55aFzPa1tk_uWs_1cyYD0XpjWg_Fn+o431hUk3AnabOeUXSQ@mail.gmail.com>
Subject: Re: kswapd craziness in 3.7
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Zlatko Calusic <zlatko.calusic@iskon.hr>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Mon, Dec 10, 2012 at 1:42 PM, Borislav Petkov <bp@alien8.de> wrote:
>
> Aren't we gonna consider the out-of-tree vbox modules being loaded and
> causing some corruptions like maybe the single-bit error above?
>
> I'm also thinking of this here: https://lkml.org/lkml/2011/10/6/317

Yup, that looks more likely, I agree.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

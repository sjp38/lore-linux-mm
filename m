Received: by wx-out-0506.google.com with SMTP id h31so2024883wxd.11
        for <linux-mm@kvack.org>; Fri, 21 Mar 2008 21:38:29 -0700 (PDT)
Message-ID: <a36005b50803212138m1c37dd9evcecb0ebda569670c@mail.gmail.com>
Date: Fri, 21 Mar 2008 21:38:29 -0700
From: "Ulrich Drepper" <drepper@gmail.com>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
In-Reply-To: <20080321172644.GG2346@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080318003620.d84efb95.akpm@linux-foundation.org>
	 <20080318095715.27120788.akpm@linux-foundation.org>
	 <20080318172045.GI11966@one.firstfloor.org>
	 <20080318104437.966c10ec.akpm@linux-foundation.org>
	 <20080319083228.GM11966@one.firstfloor.org>
	 <20080319020440.80379d50.akpm@linux-foundation.org>
	 <a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com>
	 <20080320090005.GA25734@one.firstfloor.org>
	 <a36005b50803211015l64005f6emb80dbfc21dcfad9f@mail.gmail.com>
	 <20080321172644.GG2346@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 21, 2008 at 10:26 AM, Andi Kleen <andi@firstfloor.org> wrote:
>  When would that time be? I cannot think of a single heuristic that would
>  work for both "/bin/true" and a OpenOffice start.

In both cases the stable state is reached after, say, 4 seconds.  It's
just that true terminates before the time is up.  I think something
like "trace the first N seconds" is a reasonable heuristics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

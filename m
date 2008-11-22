Date: Sat, 22 Nov 2008 12:07:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH][V2] Make get_user_pages interruptible
In-Reply-To: <6599ad830811211818g5ade68cua396713be94f80dc@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.0811220152300.18236@chino.kir.corp.google.com>
References: <604427e00811211605j20fd00bby1bac86b4cc3c380b@mail.gmail.com>  <alpine.DEB.2.00.0811211618160.20523@chino.kir.corp.google.com> <6599ad830811211818g5ade68cua396713be94f80dc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Ying Han <yinghan@google.com>, linux-mm@kvack.org, akpm <akpm@linux-foundation.org>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Nov 2008, Paul Menage wrote:

> No, I didn't exactly write it originally - the only thing I added in
> our kernel was the use of sigkill_pending() rather than checking for
> TIF_MEMDIE.
> 

That's what this patch does, its title just appears to be wrong since it 
was already interruptible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

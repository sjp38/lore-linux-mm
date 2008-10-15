Date: Wed, 15 Oct 2008 16:31:19 -0400
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: GIT head no longer boots on x86-64
Message-ID: <20081015163119.26595b8e@infradead.org>
In-Reply-To: <48F60D56.6040209@gmail.com>
References: <alpine.LFD.2.00.0810130752020.3288@nehalem.linux-foundation.org>
	<1223910693-28693-1-git-send-email-jirislaby@gmail.com>
	<20081013164717.7a21084a@lxorguk.ukuu.org.uk>
	<20081015115153.GA16413@elte.hu>
	<alpine.LFD.2.00.0810150758310.3288@nehalem.linux-foundation.org>
	<48F60D56.6040209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Oct 2008 17:33:42 +0200
Jiri Slaby <jirislaby@gmail.com> wrote:

> Users usually do
> is_vmalloc_addr(a) ? vfree(a) : kfree(a);
> Even there it makes more sense to me.
> 

I would like to point out that I greatly dislike any and all such
abuses. Either you vmalloc something or you kmalloc it. Doing it dynamic
with no way to tell? Horrible.

(in fact I might do a patch in the opposite direction; have vmalloc()
be fancy and internally try kmalloc first, if it fails, then do the
expensive stuff)

but really, you need to know what you allocated. 


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: Re: interrupt context
From: Robert Love <rml@tech9.net>
In-Reply-To: <200304150344.h3F3iVrs017946@sith.maoz.com>
References: <200304150344.h3F3iVrs017946@sith.maoz.com>
Content-Type: text/plain
Message-Id: <1050442843.3664.165.camel@localhost>
Mime-Version: 1.0
Date: 15 Apr 2003 17:40:44 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Hall <jhall@maoz.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-04-14 at 23:44, Jeremy Hall wrote:

> My quandery is where to put the lock so that both cards will use it.  I 
> need a layer that is visible to both and don't fully understand the alsa 
> architecture enough to know where to put it.

OK, I understand you now. :)

What is the relationship between the two things that are conflicting?

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Subject: Re: interrupt context
From: Robert Love <rml@tech9.net>
In-Reply-To: <200304141932.h3EJWXIW015193@sith.maoz.com>
References: <200304141932.h3EJWXIW015193@sith.maoz.com>
Content-Type: text/plain
Message-Id: <1050348936.3664.58.camel@localhost>
Mime-Version: 1.0
Date: 14 Apr 2003 15:35:36 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Hall <jhall@maoz.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-04-14 at 15:32, Jeremy Hall wrote:

> I am assuming you mean in some parent context.

No, I mean in the interrupt handler.  You can grab spin locks in
interrupt handlers.

You probably also want to disable interrupts locally.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

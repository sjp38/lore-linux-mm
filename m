Subject: Re: Documentation/vm/locking: why not hold two PT locks?
From: Robert Love <rml@ximian.com>
In-Reply-To: <8765ehe0cu.fsf@uga.edu>
References: <8765ehe0cu.fsf@uga.edu>
Content-Type: text/plain
Message-Id: <1076275778.5608.1.camel@localhost>
Mime-Version: 1.0
Date: Sun, 08 Feb 2004 16:29:38 -0500
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed L Cashin <ecashin@uga.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2004-02-08 at 16:18 -0500, Ed L Cashin wrote:

> Hi.  Documentation/vm/locking says one must not simultaneously hold
> the page table lock on mm A and mm B.  Is that true?  Where is the
> danger?

There isn't a proscribed lock ordering hierarchy, so you can deadlock.

Assume thread 1 obtains the lock on mm A.

Assume thread 2 obtains the lock on mm B.

Assume thread 1 now obtains the lock on mm B - it is taken, so spin
waiting.

Assume thread 2 now obtains the lock on mm A - it too is taken, so spin
waiting.

Boom..

	Robert Love




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

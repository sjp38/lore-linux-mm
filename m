From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14283.53227.275065.227789@dukat.scot.redhat.com>
Date: Tue, 31 Aug 1999 13:51:55 +0100 (BST)
Subject: Re: accel handling 
In-Reply-To: <37CB4E69.8C441E27@precisioninsight.com>
References: <37CB4E69.8C441E27@precisioninsight.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Owen <jens@precisioninsight.com>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 30 Aug 1999 21:39:21 -0600, Jens Owen
<jens@precisioninsight.com> said:

> Don't know if this would be any help to this discussion, be we have
> some writeups on the mechanisms we use for the DRI at
> http://www.precisioninsight.com/dr/ the most useful might be
> locking.html

Thanks.  Yes, this is exactly what I've been saying all along --- if you
want to make things go fast enough, you need cooperative locking.
Physically enforcing it in the VM wil never be able to keep up with the
pace.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

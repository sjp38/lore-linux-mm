Date: Tue, 3 Oct 2000 16:35:06 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: kiobuf questions
Message-ID: <20001003163506.N1076@redhat.com>
References: <39D9EF24.491F4389@SANgate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39D9EF24.491F4389@SANgate.com>; from gabriel@SANgate.com on Tue, Oct 03, 2000 at 05:37:24PM +0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: BenHanokh Gabriel <gabriel@SANgate.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Oct 03, 2000 at 05:37:24PM +0300, BenHanokh Gabriel wrote:
> 
> i'm trying to understand the role of the kiobuf struct in the io
> subsystem.
> 
> there are 2 fields i failed to see any reference to :
> end_io  and
> wait_queue 
> 
> now, the documentation says that this is a completion callback , but i
> never saw anyone using it.

That's because the only user of kiobuf-based IO is, for now,
synchronous.  You need end_io() callbacks and a wait queue to allow
async completion in the future.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

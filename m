Date: Tue, 25 Mar 2008 20:08:20 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC 5/8] x86_64: Add UV specific header for MMR definitions
Message-ID: <20080326000820.GA18701@infradead.org>
References: <20080324182116.GA28285@sgi.com> <20080325082756.GA6589@infradead.org> <87myoni0gp.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87myoni0gp.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Hellwig <hch@infradead.org>, Jack Steiner <steiner@sgi.com>, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 25, 2008 at 11:04:22AM +0100, Andi Kleen wrote:
> bitfields are only problematic on portable code, which this isn't.

it's still crappy to read and a bad example for others.  And last time
I heard about UV it also included an ia64 version, but that's been
loooong ago.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

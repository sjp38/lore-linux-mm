Date: Thu, 12 Oct 2000 13:10:22 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [RFC] atomic pte updates for x86 smp
In-Reply-To: <Pine.LNX.4.21.0010121126190.4301-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0010121306130.6971-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, blah@kvack.org, "Theodore Y. Ts'o" <tytso@mit.edu>, linux-kernel@vger.kernel.org, MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Oct 2000, Ingo Molnar wrote:

> [...] pgd_clear() should stay a 64-bit operation [...]

even this isnt strictly necessery - pgds and pmds are allocated in 'low
memory', and thus a simple 32-bit write to the lower 32 bits of the pgd
entry is enough to clear a PAE pgd. But it still must be a special case
due to the pgd present-bit restriction.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

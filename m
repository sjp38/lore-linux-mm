Date: Thu, 4 Nov 1999 09:10:46 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [Patch] shm cleanups
In-Reply-To: <qwwwvrzdzzu.fsf@sap.com>
Message-ID: <Pine.LNX.4.10.9911040906150.1173-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On 3 Nov 1999, Christoph Rohland wrote:

> I did test it a lot on SMP/HIGHMEM. Since 2.3.25 with and without this
> breaks on swapping shm and other high memory load conditions I could
> not verify everything. But I would like to see this in the mainstream
> kernel. I will then proceed debugging the swapping issues.

(i can see the problems too, but i've got no explanation either, working
on it as well.)

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

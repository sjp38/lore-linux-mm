Date: Wed, 8 Mar 2000 10:48:21 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] [RFT] Shared /dev/zero mmaping feature
In-Reply-To: <qwwya7tnwcz.fsf@sap.com>
Message-ID: <Pine.LNX.4.10.10003081046430.1532-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>


On 8 Mar 2000, Christoph Rohland wrote:
> 
> Because I think the current shm code should be redone in a way that
> shared anonymous pages live in the swap cache. You could say the shm
> code is a workaround :-)

Note that this is true of both shm AND /dev/zero.

Whether it is done in the current really clunky manner (ugly special shm
tables) or in the RightWay(tm) (page cache), shm and /dev/zero should
always basically be the same. The only difference between shm and
/dev/zero is how you access and set up mappings, not how the actual
mapping then works.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

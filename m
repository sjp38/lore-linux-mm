Date: Thu, 23 Jan 2003 19:26:58 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: What does pkmap stand for?
In-Reply-To: <148890000.1043258207@titus>
Message-ID: <Pine.LNX.4.44.0301231923540.2402-100000@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Jan 2003, Martin J. Bligh wrote:

> I think it's "persistant kernel map". You can't hold the atomic version
> over a schedule (unless you catch faults & patch it up).
>

Sounds plausible, that is the meaning I'll go for as it makes the most
sense. It was pointed out to me that there is another area where Permanent
Kmaps are mentioned in arch/i386/init.c but there, it actually is
permanent kmaps reserved for atomic usage

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

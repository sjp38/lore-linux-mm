Date: Tue, 17 Aug 1999 16:26:03 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <199908162339.QAA67278@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9908171619090.26053-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: alan@lxorguk.ukuu.org.uk, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 1999, Kanoj Sarcar wrote:

>							^^^ What is 2038?

#include <time.h>

main()
{
	time_t t = ~0UL >> 1;
	printf("%x, %s", t, ctime(&t));
	t++;
	printf("%x, %s", t, ctime(&t));
}

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

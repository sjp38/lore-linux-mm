Subject: Re: [patch] balanced highmem subsystem under pre7-9
References: <Pine.LNX.4.10.10005120113520.10596-200000@elte.hu>
From: Christoph Rohland <cr@sap.com>
Date: 12 May 2000 11:02:56 +0200
In-Reply-To: Ingo Molnar's message of "Fri, 12 May 2000 01:25:43 +0200 (CEST)"
Message-ID: <qwwhfc45ef3.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi Ingo,

Your patch breaks my tests again (Which run fine for some time now on
pre7):

11  1  0     0 1631764   1796  12840   0   0     0     2  115 57045   4  95   1
10  3  0     0 1420616   1796  12840   0   0     0     0  120 55463   5  95   1
9  3  0      0 998032   1796  12840   0   0     0     2  111 49490   4  96   1
VM: killing process bash
VM: killing process ipctst
VM: killing process ipctst

Greetings
		Christoph

-- 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

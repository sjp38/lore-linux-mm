Date: Sun, 23 Apr 2000 18:07:30 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <yttk8ho26s8.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.21.0004231747200.231-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Linus Torvalds <torvalds@transmeta.com>, riel@nl.linux.org, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 23 Apr 2000, Juan J. Quintela wrote:

>[..] The page is
>never locked when we enter there. [..]

That how it's designed to work. Please check my last email to linux-mm
for an explanation of why it's correct behaviour.

Andrea


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

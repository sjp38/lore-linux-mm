Date: Thu, 24 May 2007 11:57:46 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] limit print_fatal_signal() rate (was: [RFC] log out-of-virtual-memory events)
Message-ID: <20070524095746.GA15369@elte.hu>
References: <E1Hp5PV-0001Bn-00@calista.eckenfels.net> <464ED258.2010903@users.sourceforge.net> <20070520203123.5cde3224.akpm@linux-foundation.org> <20070524075835.GC21138@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070524075835.GC21138@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: righiandr@users.sourceforge.net, Bernd Eckenfels <ecki@lina.inka.de>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Ingo Molnar <mingo@elte.hu> wrote:

> [...] The only add-on change should be to not print SIGKILL events.

ah, that's already included in the version in -mm.

admittedly, the #ifdef __i386__ is quite lame, but there's no generic 
safely-try-to-show-code-at-addr function available at the moment.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

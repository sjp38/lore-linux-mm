Date: Mon, 13 Oct 2003 18:51:04 +0200
From: Roger Luethi <rl@hellgate.ch>
Subject: [RFC] State of ru_majflt
Message-ID: <20031013165104.GA14720@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The ru_majflt field of struct rusage doesn't return major page faults --
pages retrieved from cache are counted as well. POSIX and Linux man pages
don't seem to cover that particular field, but the values returned are
neither what BSD (where Linux got its copy of the struct from) does nor
what the field name suggests.

A proper solution would probably have filemap_nopage tell its caller the
correct return code. Is this considered a bug or is it a documentation
issue? How much do we care?

Roger
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Tue, 3 Oct 2000 01:10:47 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re: simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer cache mgmt problem? (fwd)
Message-ID: <20001003011047.A27493@athlon.random>
References: <Pine.LNX.4.21.0010030038370.16056-100000@elte.hu> <Pine.LNX.4.21.0010021956410.1067-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010021956410.1067-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 02, 2000 at 08:01:42PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 02, 2000 at 08:01:42PM -0300, Rik van Riel wrote:
> Eeeeeek. So pages /cannot/ lose their buffer heads ???

Page cache can definitely lose its page->buffers. page->buffers is protected by
the per-page lock. The test8 locking is completly correct.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

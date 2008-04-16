Date: Wed, 16 Apr 2008 15:01:28 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 02/19] x86: Use kbuild.h
Message-ID: <20080416130128.GF6304@elte.hu>
References: <20080414221808.269371488@sgi.com> <20080414221844.876647987@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080414221844.876647987@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, apw@shadowen.org, Sam Ravnborg <sam@ravnborg.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <clameter@sgi.com> wrote:

> Drop the macro definitions in asm-offsets_*.c and use kbuild.h

thanks Christoph, applied.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

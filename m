From: David Howells <dhowells@redhat.com>
In-Reply-To: <1179317360.2859.225.camel@shinybook.infradead.org>
References: <1179317360.2859.225.camel@shinybook.infradead.org> <20070318233008.GA32597093@melbourne.sgi.com> <18993.1179310769@redhat.com>
Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
Date: Wed, 16 May 2007 14:25:04 +0100
Message-ID: <17317.1179321904@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

David Woodhouse <dwmw2@infradead.org> wrote:

> Really? Is it _really_ going to be modified?

Well, generic_file_buffered_write() doesn't check the success of the copy
before calling commit_write(), presumably because it uses
fault_in_pages_readable() first.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

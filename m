From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC][PATCH] Rename PageChecked as PageMiscFS
Date: Thu, 11 Aug 2005 08:23:53 +1000
References: <42F57FCA.9040805@yahoo.com.au> <20050808145430.15394c3c.akpm@osdl.org> <200508110812.59986.phillips@arcor.de>
In-Reply-To: <200508110812.59986.phillips@arcor.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508110823.53593.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

8, to verify that it really does not escape into VFS or MM from NFS, in fact 
I have misgivings about end_page_fs_misc which uses this flag but has no 
in-tree users to show how it is used and, hmm, isn't even _GPL.  What is up?

And note the wrongness tacked onto the end of page-flags.h.  I didn't do it!

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

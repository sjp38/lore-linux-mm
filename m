Date: Wed, 19 Dec 2007 23:07:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 01/20] convert anon_vma list lock a read/write lock
In-Reply-To: <20071218211548.681844332@redhat.com>
Message-ID: <Pine.LNX.4.64.0712192305540.13118@schroedinger.engr.sgi.com>
References: <20071218211539.250334036@redhat.com> <20071218211548.681844332@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Note that this is a nice improvement also to page migration.

Another solution may be to use a single linked list and RCU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Fri, 25 Aug 2006 11:52:56 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Guest page hinting patches.
Message-Id: <20060825115256.26e787e4.akpm@osdl.org>
In-Reply-To: <20060824142911.GA12127@skybase>
References: <20060824142911.GA12127@skybase>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, nickpiggin@yahoo.com.au, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Thu, 24 Aug 2006 16:29:11 +0200
Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:

> Fourth version of the guest page hinting patches.

The obvious question is: "can Xen/vmware/whatever use this too?".  The
preliminary answer I get back is "might well be the case".  Hopefully we'll
hear more back soon.

So a good way to get some monentum into this work is to copy
virtualization@lists.osdl.org and lkml, try to get it some more users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

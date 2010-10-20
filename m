Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 959FB6B009D
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 10:14:25 -0400 (EDT)
Date: Wed, 20 Oct 2010 09:14:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: TMPFS Maximum File Size
In-Reply-To: <AANLkTikn_44WcCBmWUW=8E3q3=cznZNx=dHdOcgZSKgH@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1010200912270.23605@router.home>
References: <AANLkTikn_44WcCBmWUW=8E3q3=cznZNx=dHdOcgZSKgH@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Cc: hughd@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Oct 2010, Tharindu Rukshan Bamunuarachchi wrote:

> Is there any kind of file size limitation in TMPFS ?
> Our application SEGFAULT inside write() after filling 70% of TMPFS
> mount. (re-creatable but does not happen every time).

Please show us the console output and the backtrace for the segfault.

> We are using 98GB TMPFS without swap device. i.e. SWAP is turned off.
> Applications does not take approx. 20GB memory.

Are you sure? If it would take too much memory then we should see an OOM
though. Kernel logs would be very useful to figure out what is going on.

> we have Physical RAM of 128GB Intel x86 box running SLES 11 64bit.
> We use Infiniband, export TMPFS over NFS and IBM GPFS in same box.
> (hope those won't affect)

Interesting use case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

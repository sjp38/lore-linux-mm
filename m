Date: Wed, 11 Feb 2004 00:03:59 -0500 (EST)
From: James Morris <jmorris@redhat.com>
Subject: Re: 2.6.3-rc1-mm1 (SELinux + ext3 + nfsd oops)
In-Reply-To: <1076471114.4925.0.camel@chris.pebenito.net>
Message-ID: <Xine.LNX.4.44.0402110000160.10071-100000@thoron.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris PeBenito <pebenito@gentoo.org>
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Stephen Smalley <sds@epoch.ncsc.mil>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Feb 2004, Chris PeBenito wrote:

> Still oopses.  I also tried with 2.6.3-rc2, and it also oopses.

Odd, I'm unable to reproduce the problem with the same server mount
options, export options and client mount options (full details obtained
off-list).

What happens if you boot with selinux=0?

Please make sure you have the nfsd fix if using rc1-mm1.


- James
-- 
James Morris
<jmorris@redhat.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

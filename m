Date: Tue, 10 Feb 2004 21:29:02 -0500 (EST)
From: James Morris <jmorris@redhat.com>
Subject: Re: 2.6.3-rc1-mm1 (SELinux + ext3 + nfsd oops)
In-Reply-To: <1076457099.29471.39.camel@chris.pebenito.net>
Message-ID: <Xine.LNX.4.44.0402102128210.9747-100000@thoron.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris PeBenito <pebenito@gentoo.org>
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Stephen Smalley <sds@epoch.ncsc.mil>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Feb 2004, Chris PeBenito wrote:

> I got an oops on boot when nfsd is starting up on a SELinux+ext3
> machine.  It exports /home, which is mounted thusly:
> 

What happens if you try this this patch:

http://marc.theaimsgroup.com/?l=linux-kernel&m=107637246127197&w=2 ?



- James
-- 
James Morris
<jmorris@redhat.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

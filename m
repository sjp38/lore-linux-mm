Date: Sat, 31 May 2003 10:48:28 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] rmap 15j for 2.4.21-rc6
In-Reply-To: <Pine.LNX.4.44.0305301315440.4407-100000@chimarrao.boston.redhat.com>
Message-ID: <Pine.LNX.4.44.0305311047110.20941-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 30 May 2003, Rik van Riel wrote:

> The tenth maintenance release of the 15th version of the reverse
> mapping based VM is now available.
> This is an attempt at making a more robust and flexible VM
> subsystem, while cleaning up a lot of code at the same time.
> The patch is available from:
> 
>            http://surriel.com/patches/2.4/2.4.21-pre7-rmap15j
> and        http://linuxvm.bkbits.net/

Today I finally merged rmap15j forward to marcelo's latest
release.  The IO stall fixes should be especially interesting:

http://surriel.com/patches/2.4/2.4.21-rc6-rmap15j

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

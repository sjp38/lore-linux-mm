From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14323.31146.614744.699106@dukat.scot.redhat.com>
Date: Thu, 30 Sep 1999 15:54:34 +0100 (BST)
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.4.10.9909292012290.31287-100000@imperial.edgeglobal.com>
References: <14322.39431.416869.698005@dukat.scot.redhat.com>
	<Pine.LNX.4.10.9909292012290.31287-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcus Sundberg <erammsu@kieray1.p.y.ki.era.ericsson.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 29 Sep 1999 20:17:01 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

> Yikes. I think the best solution is to just put the process that owns
> the framebuffer to be put to sleep just before accel engine access. Wake
> it up once its done. 

On SMP, that still requires inter-CPU interrupts to all processors in
the worst case, as the process may already be running elsewhere.  It
doesn't get around the IPI cost.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

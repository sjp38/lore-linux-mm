From: Bartlomiej Zolnierkiewicz <B.Zolnierkiewicz@elka.pw.edu.pl>
Subject: Re: 2.6.2-rc3-mm1
Date: Wed, 4 Feb 2004 02:29:05 +0100
References: <20040202235817.5c3feaf3.akpm@osdl.org> <200402040135.56602.bzolnier@elka.pw.edu.pl> <200402040103.36504.s0348365@sms.ed.ac.uk>
In-Reply-To: <200402040103.36504.s0348365@sms.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200402040229.05918.bzolnier@elka.pw.edu.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: s0348365@sms.ed.ac.uk, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 04 of February 2004 02:03, Alistair John Strachan wrote:
> On Wednesday 04 February 2004 00:35, Bartlomiej Zolnierkiewicz wrote:
> [snip]
>
> > Oh yes, I am stupid^Wtired.  Maybe it is init_idedisk_capacity()?.
> > Can you add some more printks to idedisk_setup() to see where it hangs?
>
> I did this, and it appears to hang where you suspected,
> init_idedisk_capacity(). If this a useful datapoint, I haven't boot-tested

init_idedisk_capacity()->idedisk_check_hpa()->
->idedisk_read_native_max_address_{ext}() is a first disk access.

Probably it hangs there.  Hmm. more printks? :-)

> a kernel since 2.6.2-rc1-mm1. I can test 2.6.2-rc3 if you're puzzled by
> this result.

Does this system work ok with 2.6.2-rc1-mm1?  Weird.

--bart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

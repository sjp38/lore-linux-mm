From: Alistair John Strachan <s0348365@sms.ed.ac.uk>
Reply-To: s0348365@sms.ed.ac.uk
Subject: Re: 2.6.2-rc3-mm1
Date: Wed, 4 Feb 2004 01:03:36 +0000
References: <20040202235817.5c3feaf3.akpm@osdl.org> <200402040017.43787.s0348365@sms.ed.ac.uk> <200402040135.56602.bzolnier@elka.pw.edu.pl>
In-Reply-To: <200402040135.56602.bzolnier@elka.pw.edu.pl>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Message-Id: <200402040103.36504.s0348365@sms.ed.ac.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Bartlomiej Zolnierkiewicz <B.Zolnierkiewicz@elka.pw.edu.pl>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 04 February 2004 00:35, Bartlomiej Zolnierkiewicz wrote:
[snip]
>
> Oh yes, I am stupid^Wtired.  Maybe it is init_idedisk_capacity()?.
> Can you add some more printks to idedisk_setup() to see where it hangs?
>

I did this, and it appears to hang where you suspected, 
init_idedisk_capacity(). If this a useful datapoint, I haven't boot-tested a 
kernel since 2.6.2-rc1-mm1. I can test 2.6.2-rc3 if you're puzzled by this 
result.

> > I applied the patch on top of your previous changes, as they seemed
> > innocuous enough.
>
> OK.
>
> --bart
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Cheers,
Alistair.

personal:   alistair()devzero!co!uk
university: s0348365()sms!ed!ac!uk
student:    CS/AI Undergraduate
contact:    7/10 Darroch Court,
            University of Edinburgh.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

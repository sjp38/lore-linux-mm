Subject: Re: 2.5.68-mm4 && kexec
References: <20030502020149.1ec3e54f.akpm@digeo.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 04 May 2003 21:46:51 -0600
In-Reply-To: <20030502020149.1ec3e54f.akpm@digeo.com>
Message-ID: <m1of2iawd0.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> writes:

> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.68/2.5.68-mm4/
> 
> 
> . Much reworking of the disk IO scheduler patches due to the updated
>   dynamic-disk-request-allocation patch.  No real functional changes here.
> 
> . Included the `kexec' patch - load Linux from Linux.  Various people want
>   this for various reasons.  I like the idea of going from a login prompt to
>   "Calibrating delay loop" in 0.5 seconds.
> 
>   I tried it on four machines and it worked with small glitches on three of
>   them, and wedged up the fourth.  So if it is to proceed this code needs
>   help with testing and careful bug reporting please.

The current state of the code is that APM is not expected to work.  The
user space tool needs a fix to pass the address of the APM entry points
to the new kernel.

But beyond that everything should work baring drivers which have
problems shutting themselves down and restarting.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

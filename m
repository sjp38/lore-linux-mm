Date: Wed, 14 May 2003 10:25:26 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <51020000.1052925926@baldur.austin.ibm.com>
In-Reply-To: <20030514150653.GM8978@holomorphy.com>
References: <154080000.1052858685@baldur.austin.ibm.com>
 <20030513181018.4cbff906.akpm@digeo.com>
 <18240000.1052924530@baldur.austin.ibm.com>
 <20030514150653.GM8978@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@digeo.com>, mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--On Wednesday, May 14, 2003 08:06:53 -0700 William Lee Irwin III
<wli@holomorphy.com> wrote:

>> Which the application thinks is still part of the file, and will expect
>> its changes to be written back.  Granted, if the page fault occurred
>> just after the truncate it'd get SIGBUS, so it's clearly not a robust
>> assumption, but it will result in unexpected behavior.  Note that if the
>> application later extends the file to include this page it could result
>> in a corrupted file, since all the pages around it will be written
>> properly.
> 
> Well, for this one I'd say the app loses; it was its own failure to
> synchronize truncation vs. access, at least given that the kernel
> doesn't oops.

I think allowing a race condition that can randomly leave corrupted files
is a really bad idea, even if the app is doing something stupid.  We know
what the race is.  We should be able to prevent it.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

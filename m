Date: Mon, 22 May 2000 22:08:11 -0700 (PDT)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Linux I/O performance in 2.3.99pre
In-Reply-To: <dn4s7qpy7z.fsf@magla.iskon.hr>
Message-ID: <Pine.LNX.4.21.0005222148310.3101-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 22 May 2000, Zlatko Calusic wrote:

>Question for Andrea: is it possible to get back to the old speeds with
>tha new elevator code, or is the speed drop unfortunate effect of the
>"non-starvation" logic, and thus can't be cured?

If you don't mind about I/O scheduling latencies then just use elvtune and
set read/write latency to a big number (for example 1000000) and set the
write-bomb logic value to 128. However in misc usage you care about
responsiveness as well as latency so you probably don't want to disable
the I/O scheduler completly. The write bomb logic defaul value is too
strict probably and we may want to enlarge it to 32 or 64 to allow SCSI
to be more effective.

About the bad VM performance of the latest kernels please try again with
pre9-1 + classzone-28.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

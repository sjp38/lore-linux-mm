Message-ID: <XFMail.20011121125211.R.Oehler@GDImbH.com>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
In-Reply-To: <20011121105631.B2500@redhat.com>
Date: Wed, 21 Nov 2001 12:52:11 +0100 (MET)
Reply-To: R.Oehler@GDImbH.com
From: R.Oehler@GDImbH.com
Subject: Re: recursive lock-enter-deadlock
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 21-Nov-2001 Stephen C. Tweedie wrote:
> Hi,
> 
> On Wed, Nov 21, 2001 at 11:19:13AM +0100, R.Oehler@GDImbH.com wrote:
>> A short question (I don't have a recent 2.4.x at hand, currently):
>> Is this recursive lock-enter-deadlock (2.4.0) fixed in newer kernels?
> 
> Yes.  Seriously, 2.4.0 is so old and so full of bugs like this that
> it's really not worth spending any effort looking for problems like
> that in it.
> 
Well, maybe, but it's the one distributed in SuSE-71. And it supports
block media with sectorsizes >1k. SuSE-73 shipped 2.4.10, which seems
to have a bug in the block layer which prevents me (and out commercial
product) from using 2k-sector and 4k-sector SCSI-media. 
I have to use a kernel from a SuSE-distribution.

The bug is easy to trigger with 
"dd if=/dev/zero of=/dev/sda bs=1M count=1" 
and an MO-drive with 2k-sector-medium.
The symptom is, that sd.c gets misaligned (only 1k-aligned) 
requests and complains loudly to the syslog.)

By the way: 2.4.10-ac works, as Alan says, so what changed in the linus'
kernel and didn't change in the -ac kernel between 2.4.0 and 2.4.10 ?

Regards,
        Ralf


 -----------------------------------------------------------------
|  Ralf Oehler
|  GDI - Gesellschaft fuer Digitale Informationstechnik mbH
|
|  E-Mail:      R.Oehler@GDImbH.com
|  Tel.:        +49 6182-9271-23 
|  Fax.:        +49 6182-25035           
|  Mail:        GDI, Bensbruchstrasse 11, D-63533 Mainhausen
|  HTTP:        www.GDImbH.com
 -----------------------------------------------------------------

time is a funny concept

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

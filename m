Message-ID: <XFMail.20010516140423.R.Oehler@GDImbH.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
In-Reply-To: <009701c0ddfd$5817c0f0$bd56d2d0@SCHLEPPDOWN>
Date: Wed, 16 May 2001 14:04:23 +0200 (MEST)
Reply-To: R.Oehler@GDImbH.com
From: R.Oehler@GDImbH.com
Subject: RE: Kernel Debugger
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Frey <frey@scs.ch>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 16-May-2001 Martin Frey wrote:
> Hi
>>Is there any kernel debugger for linux like 
>>adb/crash/kadb. If so,  from
>>where can I get them.
>>

SGI is kind enough to provide many excellent tools around 
the linux kernel. There is also a very handy kernel debugger
("kdb", as patch to the kernel source tree, which means really 
native). It's usable also as remote debugger over a serial line.
SGI keeps this debugger very up-to-date, so there are patches
even for the leading-edge-pre-versions of the kernel.

See
        http://oss.sgi.com/projects/
and
        ftp://oss.sgi.com/www/projects/kdb/download/ix86/


Regards,
        Ralf Oehler


 -----------------------------------------------------------------
|  Ralf Oehler
|  GDI - Gesellschaft fuer Digitale Informationstechnik mbH
|
|  E-Mail:      R.Oehler@GDImbH.com
|  Tel.:        +49 6182-9271-23 
|  Fax.:        +49 6182-25035           
|  Mail:        GDI, Bensbruchstra_e 11, D-63533 Mainhausen
|  HTTP:        www.GDImbH.com
 -----------------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

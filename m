Message-ID: <XFMail.20020306084829.R.Oehler@GDAmbH.com>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Date: Wed, 06 Mar 2002 08:48:29 +0100 (MET)
From: Ralf Oehler <R.Oehler@GDAmbH.com>
Subject: Support for sectorsizes > 4KB ?
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scsi <linux-scsi@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, List

In the not-so-far future there will occure MO media on the market with
40 to 120 Gigabytes of capacity and sectorsizes of 8 KB and maybe more.
It's called "UDO" technology.

Is there any way to support block devices with sectors larger than 4KB ?

Regards,
        Ralf


 --------------------------------------------------------------------------
|  Ralf Oehler                          
|                                       
|  GDA - Gesellschaft fuer Digitale                              _/
|        Archivierungstechnik mbH & CoKG                        _/
|  Ein Unternehmen der Bechtle AG               #/_/_/_/ _/_/_/_/ _/_/_/_/
|                                              _/    _/ _/    _/       _/
|  E-Mail:      R.Oehler@GDAmbH.com           _/    _/ _/    _/ _/    _/
|  Tel.:        +49 6182-9271-23             _/_/_/_/ _/_/_/#/ _/_/_/#/
|  Fax.:        +49 6182-25035                    _/
|  Mail:        GDA, Bensbruchstrasse 11,   _/_/_/_/
|               D-63533 Mainhausen      
|  HTTP:        www.GDAmbH.com         
 --------------------------------------------------------------------------

time is a funny concept
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

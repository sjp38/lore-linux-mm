Date: Mon, 13 May 2002 11:32:53 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: RE: [RFC][PATCH] IO wait accounting
In-Reply-To: <AAEGIMDAKGCBHLBAACGBCEDDCIAA.balbir.singh@wipro.com>
Message-ID: <Pine.LNX.4.44L.0205131131380.32261-200000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY="----=_NextPartTM-000-aabc047b-6650-11d6-a942-00b0d0d06be8"
Content-ID: <Pine.LNX.4.44L.0205131131381.32261@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: BALBIR SINGH <balbir.singh@wipro.com>
Cc: Zlatko Calusic <zlatko.calusic@iskon.hr>, Bill Davidsen <davidsen@tmr.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

------=_NextPartTM-000-aabc047b-6650-11d6-a942-00b0d0d06be8
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.44L.0205131131382.32261@imladris.surriel.com>

On Mon, 13 May 2002, BALBIR SINGH wrote:

> http://sunsite.uakom.sk/sunworldonline/swol-08-1997/swol-08-insidesolaris.html
>
> Simple and straight forward implementation of a per-cpu iowait statistics
> counter.

Hehe, so straight forward that I already did this part last
week, before searching around for papers like this.

At least it means the stats will be fully compatible and
sysadmins won't get lost (like they do with the different
meanings of the load average).

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

------=_NextPartTM-000-aabc047b-6650-11d6-a942-00b0d0d06be8
Content-Type: TEXT/PLAIN; NAME="Wipro_Disclaimer.txt"
Content-ID: <Pine.LNX.4.44L.0205131131383.32261@imladris.surriel.com>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME="Wipro_Disclaimer.txt"

**************************Disclaimer************************************
      


Information contained in this E-MAIL being proprietary to Wipro Limited
is 'privileged' and 'confidential' and intended for use only by the
individual or entity to which it is addressed. You are notified that any
use, copying or dissemination of the information contained in the E-MAIL
in any manner whatsoever is strictly prohibited.



 ********************************************************************

------=_NextPartTM-000-aabc047b-6650-11d6-a942-00b0d0d06be8--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

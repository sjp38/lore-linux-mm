Received: from imsantv20.netvigator.com (imsantv20 [127.0.0.1])
	by imsantv20.netvigator.com (8.12.9/8.12.9) with ESMTP id h4VFqdsx021619
	for <linux-mm@kvack.org>; Sat, 31 May 2003 23:52:39 +0800
From: Michael Frank <mflt1@micrologica.com.hk>
Subject: Re: [PATCH] rmap 15j for 2.4.21-rc6
Date: Sat, 31 May 2003 23:52:15 +0800
References: <Pine.LNX.4.44.0305311047110.20941-100000@chimarrao.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0305311047110.20941-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200305312348.42499.mflt1@micrologica.com.hk>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Saturday 31 May 2003 22:48, Rik van Riel wrote:
>
> Today I finally merged rmap15j forward to marcelo's latest
> release.  The IO stall fixes should be especially interesting:
>

Patched rc6 ex BK OK and compiled with gcc295-3 OK

On a P4/533-2.4Ghz/512MB with udma5 IDE ~50MB/s:

Shows severe interactivity problems and hangs

Scroll and mouse hangs and delayed response to keyboard 
greater 1s are easily observable.

Test script: tstinter V0.1 

http://www.ussg.iu.edu/hypermail/linux/kernel/0305.3/1291.html

To reproduce cd to dir with script and execute from X console: 
  ./tstinter start

More instructions in script

Other kernel results: 
   2.4.18 PIO DIES - see msg w. script, 
   2.4.18 udma2 OK, 
   2.4.19 Bad, 
   2.4.20 Bad, 
   2.4.21-rc1 Bad, 
   2.4.21-rc6 OK 
   2.5.70,-mm1,-mm2,-mm3 (OK) 

Regards
Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.33-mm3 dbench hang and 2.5.33 page allocation failures
Date: Thu, 5 Sep 2002 21:15:05 +0200
References: <1031246639.2799.68.camel@spc9.esa.lanl.gov>
In-Reply-To: <1031246639.2799.68.camel@spc9.esa.lanl.gov>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17n25p-0006AQ-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>, Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 05 September 2002 19:23, Steven Cole wrote:
> I booted 2.5.33-mm3 and ran dbench with increasing
> numbers of clients: 1,2,3,4,6,8,10,12,16,etc. while
> running vmstat -n 1 600 from another terminal.
> 
> After about 3 minutes, the output from vmstat stopped,
> and the dbench 16 output stopped.  The machine would
> respond to pings, but not to anything else. I had to 
> hard-reset the box. Nothing interesting was saved in 
> /var/log/messages. I have the output from vmstat if needed.

That happened to me yesterday while hacking 2.4 and the reason was
failed oom detection.  Memory leak?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

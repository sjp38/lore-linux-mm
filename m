Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 3F30B6B0070
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 16:03:28 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id wy12so755712pbc.35
        for <linux-mm@kvack.org>; Fri, 15 Feb 2013 13:03:27 -0800 (PST)
Message-ID: <511EA29C.3030301@linaro.org>
Date: Fri, 15 Feb 2013 13:03:24 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC][ATTEND] Volatile Ranges
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Sorry for being late here.

I wanted to propose some further discussion on the volatile ranges concept.

Basically trying to sort out a coherent story around:

* My attempts at volatile ranges for shared tmpfs files (similar 
functionality as Android's ashmem provides)

* Minchan's volatile ranges for anonymous memory

* How to track page volatility & purged state (via VMAs vs file 
address_space)

* Purged data semantics (ie: Mozilla's request for SIGBUS on purged data 
access vs zero fill)

* Aging anonymous pages in swapless systems

thanks
-john




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

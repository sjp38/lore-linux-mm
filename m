Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 14C096B004D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 04:36:27 -0400 (EDT)
Received: from localhost (filter1.syneticon.net [192.168.113.83])
	by mx03.syneticon.net (Postfix) with ESMTP id EAFA535D73
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 09:42:24 +0100 (CET)
Received: from mx03.syneticon.net ([192.168.113.84])
	by localhost (mx03.syneticon.net [192.168.113.83]) (amavisd-new, port 10025)
	with ESMTP id HtzS20fabd4g for <linux-mm@kvack.org>;
	Tue, 24 Mar 2009 09:42:20 +0100 (CET)
Received: from [192.168.10.145] (koln-4db483fa.pool.einsundeins.de [77.180.131.250])
	by mx03.syneticon.net (Postfix) with ESMTPSA
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 09:42:20 +0100 (CET)
Message-ID: <49C89CE0.2090103@wpkg.org>
Date: Tue, 24 Mar 2009 09:42:08 +0100
From: Tomasz Chmielewski <mangoo@wpkg.org>
MIME-Version: 1.0
Subject: why my systems never cache more than ~900 MB?
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On my (32 bit) systems with more than 1 GB memory it is impossible to cache more than about 900 MB. Why?

Caching never goes beyond ~900 MB (i.e. when I read a mounted drive with dd):


# free
             total       used       free     shared    buffers     cached
Mem:       2076164     966788    1109376          0     855132      68932
-/+ buffers/cache:      42724    2033440
Swap:      2097144          0    2097144


Same behaviour on 32 bit machines with 4 GB RAM.

No problems on 64 bit machines.
I have one 32 bit machine that caches beyond ~900 MB without problems.

Is it some kernel/proc/sys setting that I'm missing?


-- 
Tomasz Chmielewski
http://wpkg.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

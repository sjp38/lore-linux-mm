Received: from oscar (localhost [127.0.0.1])
	by oscar.casa.dyndns.org (Postfix) with SMTP id 3EDF4ACD5D
	for <linux-mm@kvack.org>; Fri,  2 Jun 2000 10:33:41 -0400 (EDT)
From: Ed Tomlinson <tomlins@cam.org>
Reply-To: tomlins@cam.org
Subject: Jun 2th mm patch on top of ac7
Date: Fri, 2 Jun 2000 10:26:38 -0400
Content-Type: text/plain
MIME-Version: 1.0
Message-Id: <00060210334000.01298@oscar>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Subjective performace of the system is much nicer with the Rik's june 2th 
patch applied on test1-ac7.  I am now able to have a news cache, a java 
server, browse and play mp3(s) without the jerkness of the May 31th patch.

Some vmstat numbers follow:

   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 1  0  0  19204   3764   5880  38624  11   0     9     0  130   646  11   2  88
 3  0  0  19204   2640   6044  39512  22   0    25     4  204  1499  14   6  80
 1  0  0  19204   2788   5992  39484   0   0    18     0  196   978  12   2  87
 6  0  0  19204   2568   5992  39660   0   0     3     0  152   708   7   2  91
 1  0  0  18680   3300   6072  40308  24   0    16     6  207   884   8   2  90
 0  0  0  18680   4800   6096  38168   0   0     5     1  189  1021  10   2  88
 4  0  0  18680   5332   6096  38224   0   0     0     0  176   853   9   3  87

The box is not heavily loaded.  One difference from earlier vm(s).  The ammout of
memory allocated to buff is less now (was 10000-15000).

I am not subscribed here so please repond to my personal address.  

TIA,

Ed Tomlinson (ontadata) <tomlins@cam.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Message-ID: <394F0B6C.3925591B@norran.net>
Date: Tue, 20 Jun 2000 08:13:00 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: latancy test of -ac22-riel
References: <Pine.LNX.4.21.0006192052001.7938-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi all,

Things are looking better and better :-)
Running with SCHED_FIFO now gives most interrupt to process
latencies below 3 ms !!!
(streaming 1.5 times RAM; read, write, copy tested)

But there are some, nowadays very few, spikes that hurts...
Worst is above 100 ms

But in this kernel does not have the loop limits in shrink_mmap

/RogerL

PS
  Used test programs are at:
  http://www.gardena.net/benno/linux/audio 
  for test programs.
DS

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

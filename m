Received: from d1o43.telia.com (d1o43.telia.com [194.22.195.241])
	by maila.telia.com (8.9.3/8.9.3) with ESMTP id PAA23688
	for <linux-mm@kvack.org>; Thu, 18 Jan 2001 15:05:16 +0100 (CET)
Received: from dox (t7o43p30.telia.com [194.237.168.150])
	by d1o43.telia.com (8.10.2/8.10.1) with SMTP id f0IE4xB28469
	for <linux-mm@kvack.org>; Thu, 18 Jan 2001 15:05:15 +0100 (CET)
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
Subject: DATAPOINT: 2.4.1-pre8 v. other
Date: Thu, 18 Jan 2001 15:00:11 +0100
MIME-Version: 1.0
Message-Id: <01011815001100.01243@dox>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I have performed my usual streaming write, copy, read, diff, dbench,
and mmap002

2.4.1-pre8 (with emu10k patch) is slower than 2.2.18 when streaming,
but much better when running dbench. Best of the ones I have tested is
the 2.4.1-pre1+marcelo (was there any bugs in there that helped performance?)

I do also run Quintelas mmap002 one interesting aspect is that the used
time doubled...??? pre8 took 4m21 to finish most others has taken below
2m30.... (this might actually be a good sign - hard to tell...)


/RogerL
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

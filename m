Received: (from uucp@localhost)
	by annwfn.erfurt.thur.de (8.10.1/8.10.1) with UUCP id e3CEVrS00584
	for linux-mm@kvack.org; Wed, 12 Apr 2000 16:31:53 +0200
Received: from nibiru.pauls.erfurt.thur.de (uucp@localhost)
	by pauls.erfurt.thur.de (8.9.3/8.9.3) with bsmtp id QAA02979
	for linux-mm@kvack.org; Wed, 12 Apr 2000 16:29:31 +0200
Received: from nibiru.pauls.erfurt.thur.de (weigelt@localhost [127.0.0.1])
	by nibiru.pauls.erfurt.thur.de (8.9.3/8.9.3) with ESMTP id DAA01179
	for <linux-mm@kvack.org>; Wed, 12 Apr 2000 03:26:26 +0200
Message-ID: <38F3D0C1.88A1ECAD@nibiru.pauls.erfurt.thur.de>
Date: Wed, 12 Apr 2000 03:26:25 +0200
From: Enrico Weigelt <weigelt@nibiru.pauls.erfurt.thur.de>
Reply-To: weigelt@nibiru.pauls.erfurt.thur.de
MIME-Version: 1.0
Subject: swapspace in video memory ?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

hi folks,

i've got an PII machine with 64MB ram and RivaTNT with 16MB ram.
normally i don't use the Riva's rendering functions and so i only 
use about 1 meg of its ram. 

now i'd like to have an swapspace (or perhaps system memory?) in 
the free video memory.

how could i do this ?

regards,
ew.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

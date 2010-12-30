Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7DB566B00B6
	for <linux-mm@kvack.org>; Thu, 30 Dec 2010 18:24:04 -0500 (EST)
Received: by fxm12 with SMTP id 12so5091568fxm.14
        for <linux-mm@kvack.org>; Thu, 30 Dec 2010 15:24:01 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 30 Dec 2010 23:24:00 +0000
Message-ID: <AANLkTikrPWqH1tiG4Hx8eg09+Sn_cJ=EMbBVWrSabCF1@mail.gmail.com>
Subject: CLOCK-Pro algorithm
From: Adrian McMenamin <lkmladrian@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Adrian McMenamin <adrianmcmenamin@gmail.com>
List-ID: <linux-mm.kvack.org>

I originally tried to send this to the addresses for Song Jiang, Feng
Chen and Xiaodong Zhang on the USENIX paper but it bounced from all of
them. So I hope you will indulge me if I send it to the list in the
hope it might reach them. Or perhaps someone here could answer the
questions below.

Many thanks

Adrian

Dear all,

I am just beginning work on an MSc project on Linux memory management
and have been reading your paper to the 2005 USENIX Annual Technical
Conference. I was wondering what the current status of this algorithm
is as regards the Linux kernel.

I can find this: http://linux-mm.org/ClockProApproximation and patches
for testing with the 2.6.12 kernel but am not entirely clear as to
whether this algorithm was included: certainly all the books I have
read still talk of the LRU lists that are similar to the 2Q model.

Could you enlighten me?

Many thanks in advance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: (from uucp@localhost)
	by annwfn.erfurt.thur.de (8.9.3/8.9.2) with UUCP id VAA27206
	for linux-mm@kvack.org; Sun, 9 Jan 2000 21:48:22 +0100
Received: from nibiru.pauls.erfurt.thur.de (uucp@localhost)
	by pauls.erfurt.thur.de (8.9.3/8.9.3) with bsmtp id VAA04574
	for linux-mm@kvack.org; Sun, 9 Jan 2000 21:38:32 +0100
Received: from nibiru.pauls.erfurt.thur.de (localhost [127.0.0.1])
	by nibiru.pauls.erfurt.thur.de (8.9.3/8.9.3) with ESMTP id RAA02966
	for <linux-mm@kvack.org>; Sat, 8 Jan 2000 17:01:22 GMT
Message-ID: <38776D61.56A4EC24@nibiru.pauls.erfurt.thur.de>
Date: Sat, 08 Jan 2000 17:01:21 +0000
From: Enrico Weigelt <weigelt@nibiru.pauls.erfurt.thur.de>
Reply-To: weigelt@nibiru.pauls.erfurt.thur.de
MIME-Version: 1.0
Subject: bdflush
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

hello,

i'm wondering why bdflush is really needed anymore ...

i've read somewhere, bdflush was invented in times, when linux didn't
have
kernel-threads. bdflush does an syscall which never returns ...
hmm... nice way to have a process in kernel space.

but now linux _has_ kernel threads. isn't it better to start an kernel
thread ?
i know, that bdflush configures something ... this could be done by an
kernel module.

aah.. (OT) question about kernmods. can an kernel module set it's status
to 
autounload, even if it was loaded manually ?
(this would be good for configuration modules: if there's something to
configure 
in the kernel, load an module with some params, which does this config
and 
unloads itself when done - no need for huge config interfaces like
sysctl() ...)

bye,
enrico
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/

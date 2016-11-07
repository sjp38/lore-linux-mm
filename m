Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFEBB6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 11:25:45 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so52859812pfb.6
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 08:25:45 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 75si32132107pfa.10.2016.11.07.08.25.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 08:25:45 -0800 (PST)
Subject: Patch "x86/microcode/AMD: Fix more fallout from CONFIG_RANDOMIZE_MEMORY=y" has been added to the 4.8-stable tree
From: <gregkh@linuxfoundation.org>
Date: Mon, 07 Nov 2016 17:24:26 +0100
Message-ID: <147853586658196@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@suse.de, agruenba@redhat.com, bp@alien8.de, brgerst@gmail.com, dvlasenk@redhat.com, gregkh@linuxfoundation.org, hpa@zytor.com, jpoimboe@redhat.com, linux-mm@kvack.org, luto@amacapital.net, luto@kernel.org, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, rpeterso@redhat.com, swhiteho@redhat.com, tglx@linutronix.de, torvalds@linux-foundation.org
Cc: stable@vger.kernel.org, stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/microcode/AMD: Fix more fallout from CONFIG_RANDOMIZE_MEMORY=y

to the 4.8-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-microcode-amd-fix-more-fallout-from-config_randomize_memory-y.patch
and it can be found in the queue-4.8 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.

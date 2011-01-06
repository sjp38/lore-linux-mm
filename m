Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 928716B0087
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 21:21:07 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p062KZHd010369
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 5 Jan 2011 18:20:36 -0800
Received: by iwn40 with SMTP id 40so16629106iwn.14
        for <linux-mm@kvack.org>; Wed, 05 Jan 2011 18:20:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110106111231.4fc98855.kamezawa.hiroyu@jp.fujitsu.com>
References: <bug-25042-27@https.bugzilla.kernel.org/> <20110104135148.112d89c5.akpm@linux-foundation.org>
 <20110106111231.4fc98855.kamezawa.hiroyu@jp.fujitsu.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 5 Jan 2011 18:20:15 -0800
Message-ID: <AANLkTikF75EzTQAgCSVf-yGva2ioTHUVa2VTJ949EQ_q@mail.gmail.com>
Subject: Re: [Bug 25042] New: RAM buffer I/O resource badly interacts with
 memory hot-add
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-acpi@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, petr@vandrovec.name, akataria@vmware.com
List-ID: <linux-mm.kvack.org>

On Wed, Jan 5, 2011 at 6:12 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> Hmm ? Why do you need to place "hot-added" memory's address range next to System
> RAM ? Sparsemem allows sparse memory layout.

Well, even without sparsemem, why couldn't the initial memory image
just be more nicely aligned to 256MB or something?

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Thu, 12 Oct 2000 01:56:32 -0700
Message-Id: <200010120856.BAA08092@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <Pine.LNX.4.21.0010120921510.1191-100000@elte.hu> (message from
	Ingo Molnar on Thu, 12 Oct 2000 10:13:48 +0200 (CEST))
Subject: Re: [RFC] atomic pte updates for x86 smp
References: <Pine.LNX.4.21.0010120921510.1191-100000@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: torvalds@transmeta.com, blah@kvack.org, tytso@mit.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   the PAE pgd 'anomaly' should not affect this case, because we never
   clear neither user-space pgds, nor user-space pmds in PAE mode

Eh?

munmap() --> clear_page_tables() --> free_one_pgd() --> pgd_clear

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Thu, 12 Oct 2000 12:05:48 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [RFC] atomic pte updates for x86 smp
In-Reply-To: <200010120856.BAA08092@pizda.ninka.net>
Message-ID: <Pine.LNX.4.21.0010121126190.4301-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, blah@kvack.org, "Theodore Y. Ts'o" <tytso@mit.edu>, linux-kernel@vger.kernel.org, MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Oct 2000, David S. Miller wrote:

>    clear neither user-space pgds, nor user-space pmds in PAE mode
> 
> Eh?
> 
> munmap() --> clear_page_tables() --> free_one_pgd() --> pgd_clear

you are right, i was focused too much on the swapping case. I dont think
munmap() is a problem in the PAE case. pgd_clear() should stay a 64-bit
operation (like in Ben's patch) because we could get a legitimate TLB
flush between two 32-bit writes. (the 4 pgd entries are otherwise cached
in the CPU core, only TLB flushes reload them.)

	Ingo



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

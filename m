Date: Thu, 11 Jan 2001 08:38:39 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: pre2 swap_out() changes
Message-ID: <Pine.LNX.4.21.0101110825460.9296-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus,

While looking at pre2 VM changes, I've saw this thing:

static int swap_out(unsigned int priority, int gfp_mask)
{
        int counter;
        int retval = 0;
        struct mm_struct *mm = current->mm;

        /* Always start by trying to penalize the process that is 
	allocating memory */
        if (mm)
                retval = swap_out_mm(mm, swap_amount(mm));


Since no process calls swap_out() directly, I dont see any sense on the
comment above. 

Is this really bogus or you're planning something? 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

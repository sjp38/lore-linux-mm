Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Snapshot of shared page tables
Date: Wed, 2 Oct 2002 18:51:41 +0200
References: <45850000.1033570655@baldur.austin.ibm.com>
In-Reply-To: <45850000.1033570655@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17wmit-0001bH-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 02 October 2002 16:57, Dave McCracken wrote:
> 
> Ok, here it is.  This patch works for my simple tests, both under UP and
> SMP, including under memory pressure.  I'd appreciate anyone who'd like to
> take it and beat on it.  Please let me know of any problems you find.
> 
> The patch is against this morning's 2.5 BK tree.

Interesting, you substituted pte_page_lock(ptepage) for mm->page_table_lock.
Could you wax poetic about that, please?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

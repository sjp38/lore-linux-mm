Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize away pte_chains for single mappings
Date: Sat, 13 Jul 2002 15:13:35 +0200
References: <55160000.1026239746@baldur.austin.ibm.com>
In-Reply-To: <55160000.1026239746@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17TMiO-0003IR-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@zip.com.au>
List-ID: <linux-mm.kvack.org>

On Tuesday 09 July 2002 20:35, Dave McCracken wrote:
> 
> Here's a patch that optimizes out using a struct pte_chain when there's
> only one mapping for that page.  It re-uses the pte_chain pointer in struct
> page, with an appropriate flag.  The patch is based on Rik's latest 2.5.25
> rmap patch.
> 
> I've done basic testing on it (it boots and runs simple commands).
> 
> This version of the patch uses an anonymous union, so it only builds with
> gcc 3.x.  I'm working on an alternate version of the patch, but wanted to
> get this one out for people to look at.

Why are we using up valuable real estate in page->flags when the low bit
of page->pte_chain is available?

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

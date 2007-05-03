Date: Thu, 3 May 2007 08:22:23 -0500
From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070503132223.GB13015@kryten>
References: <20070503022107.GA13592@kryten> <200705031059.18590.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200705031059.18590.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, clameter@sgi.com, nish.aravamudan@gmail.com, mel@csn.ul.ie, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Hi,
 
> > Im guessing registering empty remote zones might make the SGI guys a bit
> > unhappy, maybe we should just force the registration of empty local
> > zones? Does anyone care?
> 
> I care. Don't do that please. Empty nodes cause all kinds of problems.

Could you be more specific? How else do we fix the problem I just
identified?

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 7 Jan 2008 11:46:51 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: RFC/Patch Make Page Tables Relocatable Part 0/2
In-Reply-To: <d43160c70801040757n44b81619qb71366a73e68952@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0801071144300.23617@schroedinger.engr.sgi.com>
References: <d43160c70801040757n44b81619qb71366a73e68952@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks for your work on this. This is important for memory 
hotplug, page migration and memory defrag.

Could you follow the procedures outlined in 
Documentation/SubmittingPatches? In particular please put the patches in 
line and add the proper headers to them. That will make it easier to 
review and you will get more comments on the patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

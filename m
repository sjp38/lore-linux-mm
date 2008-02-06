Date: Wed, 6 Feb 2008 15:08:39 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] mm: fix misleading __GFP_REPEAT related comments
In-Reply-To: <20080206230512.GE3477@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0802061508150.21988@schroedinger.engr.sgi.com>
References: <20080206230512.GE3477@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: melgor@ie.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2008, Nishanth Aravamudan wrote:

> To clarify, the flags' semantics are:
> 
>     __GFP_NORETRY means try no harder than one run through __alloc_pages
> 
>     __GFP_REPEAT means __GFP_NOFAIL

The __GFP_REPEAT == __GFP_NOFAIL? 

If so then remove __GFP_REPEAT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

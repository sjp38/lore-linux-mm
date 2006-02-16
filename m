From: Andi Kleen <ak@suse.de>
Subject: Re: page migration: Fix MPOL_INTERLEAVE behavior for migration via mbind()
Date: Thu, 16 Feb 2006 22:11:33 +0100
References: <Pine.LNX.4.64.0602161238270.16786@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0602161238270.16786@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602162211.34429.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Thursday 16 February 2006 21:42, Christoph Lameter wrote:
> migrate_pages_to() allocates a list of new pages on the intended target 
> node or with the intended policy and then uses the list of new pages as 
> targets for the migration of a list of pages out of place.

Looks ok to me.
-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

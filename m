Date: Thu, 13 Feb 2003 13:52:39 -0500
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH] early, early ioremap
Message-ID: <20030213135239.B22719@redhat.com>
References: <3E4B4F36.70209@us.ibm.com> <18530000.1045160770@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18530000.1045160770@[10.10.2.4]>; from mbligh@aracnet.com on Thu, Feb 13, 2003 at 10:26:12AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 13, 2003 at 10:26:12AM -0800, Martin J. Bligh wrote:
> Either a per-page bitmap of used areas, a fixmap-type array, or simply
> making the user keep track of it would be fine ...
> 
> Opinions?

Why not use an early kmap_atomic()?  It's easy enough to enable the code 
on a non-highmem build as you would need for this purpose.  Also, making 
atomic kmaps able to map io space could be useful to replace ACPI's kludge 
too.

		-ben
-- 
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

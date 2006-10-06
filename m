Date: Fri, 6 Oct 2006 10:00:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] zoneid fix up calculations for ZONEID_PGSHIFT
In-Reply-To: <20061006144535.GA18583@shadowen.org>
Message-ID: <Pine.LNX.4.64.0610060959160.14519@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610021008510.12554@schroedinger.engr.sgi.com>
 <20061006144535.GA18583@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Oct 2006, Andy Whitcroft wrote:

> How does this look, against 2.6.19-mm3.

Looks fine to me. Its against 2.6.18-mm3 I think (unless you have some way 
to do time travel..)

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

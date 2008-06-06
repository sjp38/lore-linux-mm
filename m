Subject: Re: [RFC][PATCH 1/2] pass mm into pagewalkers
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20080606173137.24513039@kernel>
References: <20080606173137.24513039@kernel>
Content-Type: text/plain
Date: Fri, 06 Jun 2008 13:06:12 -0500
Message-Id: <1212775572.14718.14.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Hans Rosenfeld <hans.rosenfeld@amd.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-06-06 at 10:31 -0700, Dave Hansen wrote:
> We need this at least for huge page detection for now.
> 
> It might also come in handy for some of the other
> users.

This looks great, modulo some whitespace nits.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: Re: Use of __pa() with CONFIG_NONLINEAR
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <35960000.1091044039@flay>
References: <1090965630.15847.575.camel@nighthawk>
	 <20040728181645.GA13758@w-mikek2.beaverton.ibm.com>
	 <35960000.1091044039@flay>
Content-Type: text/plain
Message-Id: <1091045615.2871.364.camel@nighthawk>
Mime-Version: 1.0
Date: Wed, 28 Jul 2004 13:13:35 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Mike Kravetz <kravetz@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Joel Schopp <jschopp@austin.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-07-28 at 12:47, Martin J. Bligh wrote:
> Can someone explain the necessity to create the new address space? We don't
> need it with the current holes between nodes, and from my discssions with
> Andy, I'm now unconvinced it's necessary.

Actually, the new address space is quite separated from what I'm
proposing here.  I'd prefer to discuss that part when we have an
implementation surrounding it.  I can explain it now if you'd like, but
it's going to be a bit harder with no code.  

The reason we need boot-time __{p,v}a() macros is really quite separate
from the new (logical) address space.  These new macros are just so we
can assume flat addressing during boot or compile-time, before any
nonlinear structures are set up.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

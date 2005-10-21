Date: Fri, 21 Oct 2005 08:42:33 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 1/4] Swap migration V3: LRU operations
In-Reply-To: <1129877795.26533.12.camel@localhost>
Message-ID: <Pine.LNX.4.62.0510210841160.23212@schroedinger.engr.sgi.com>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
  <20051020225940.19761.93396.sendpatchset@schroedinger.engr.sgi.com>
 <1129874762.26533.5.camel@localhost>  <aec7e5c30510202327l7ce5a89ax7620241ba57a4efa@mail.gmail.com>
 <1129877795.26533.12.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Magnus Damm <magnus.damm@gmail.com>, Andrew Morton <akpm@osdl.org>, Mike Kravetz <kravetz@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Oct 2005, Dave Hansen wrote:

> Hirokazu's page migration patches have some functions called the exact
> same things: __putback_page_to_lru, etc... although they are simpler.
> Not my code, but it would be nice to acknowledge if ideas were coming
> from there.

Ok, I will add note to that effect. The basic idea is 
already inherent in the shrink_list logic, so I thought it would be okay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 27 Sep 2005 12:30:55 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 1/9] add defrag flags
Message-Id: <20050927123055.0ad9c2b4.pj@sgi.com>
In-Reply-To: <433991A0.7000803@austin.ibm.com>
References: <4338537E.8070603@austin.ibm.com>
	<43385412.5080506@austin.ibm.com>
	<21024267-29C3-4657-9C45-17D186EAD808@mac.com>
	<1127780648.10315.12.camel@localhost>
	<20050926224439.056eaf8d.pj@sgi.com>
	<433991A0.7000803@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: haveblue@us.ibm.com, mrmacman_g4@mac.com, akpm@osdl.org, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kravetz@us.ibm.com
List-ID: <linux-mm.kvack.org>

Joel wrote:
> We may not be able to use the same flag after all due to our need to mark buffer 
> pages as user.

Agreed - we have separate flags.  I want exactly user address space
pages.  You want really easy to reclaim pages.  You have good
performance justifications for your choice.  I have just "design
purity", so if for some reason there was a dire shortage of GFP bits,
I suspect it is I who should give, not you.

> > +#define __GFP_BITS_SHIFT 21	/* Room for 20 __GFP_FOO bits */
> 
> Yep.

Once this is merged with current Linux, which already has GFP_HARDWALL,
I presume you will be back up to 21 bits, code and comment.

As I noted in another message the "USER" and the comment in:

#define __GFP_USER	0x40000u /* User is a userspace user */

are a bit misleading now.  Perhaps GFP_EASYRCLM?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: Re: Use of __pa() with CONFIG_NONLINEAR
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <49810000.1091045752@flay>
References: <1090965630.15847.575.camel@nighthawk>
	 <20040728181645.GA13758@w-mikek2.beaverton.ibm.com>
	 <35960000.1091044039@flay> <1091045615.2871.364.camel@nighthawk>
	 <49810000.1091045752@flay>
Content-Type: text/plain
Message-Id: <1091046231.2871.379.camel@nighthawk>
Mime-Version: 1.0
Date: Wed, 28 Jul 2004 13:23:52 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Mike Kravetz <kravetz@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Joel Schopp <jschopp@austin.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-07-28 at 13:15, Martin J. Bligh wrote:
> However ... what happens to functions calling __pa that are called from 
> boot time and run time code?

I've actually only run into one of those so far that I know of, and that
was on ppc64 (i386 had none that I found).  In that one case, I used an
if(unlikely()) to optimize for the run-time one.  There might be more,
but I think they're rare enough to just code it with an if() in each
case.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

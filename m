Date: Mon, 11 Jul 2005 23:11:50 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [Fwd: [PATCH 2/4] cpusets new __GFP_HARDWALL flag]
Message-Id: <20050711231150.4d72c8a3.pj@sgi.com>
In-Reply-To: <1121145895.5446.1.camel@localhost>
References: <1121101013.15095.19.camel@localhost>
	<42D2AE0F.8020809@austin.ibm.com>
	<20050711195540.681182d0.pj@sgi.com>
	<1121145895.5446.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: jschopp@austin.ibm.com, linux-mm@kvack.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Dave wrote:
> four types ==> two GFP bits

Ok.  Guess I should read the patch to figure out
what these 4 types are (and which subsets thereof
map to my 2 types USER and !USER aka KERN.)

If there is not a surjective function from your
4 types to my 2 types, then I can't so easily
share your GFP bits.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

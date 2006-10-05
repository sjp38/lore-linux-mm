Date: Wed, 4 Oct 2006 21:53:06 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
Message-Id: <20061004215306.e5670f46.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64N.0610042138580.5625@attu4.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0>
	<20061001231811.26f91c47.pj@sgi.com>
	<Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
	<20061001234858.fe91109e.pj@sgi.com>
	<Pine.LNX.4.64N.0610020001240.7510@attu3.cs.washington.edu>
	<20061002014121.28b759da.pj@sgi.com>
	<20061003111517.a5cc30ea.pj@sgi.com>
	<Pine.LNX.4.64N.0610031231270.4919@attu3.cs.washington.edu>
	<20061004084552.a07025d7.pj@sgi.com>
	<Pine.LNX.4.64N.0610041456480.19080@attu2.cs.washington.edu>
	<20061004192714.20412e08.pj@sgi.com>
	<Pine.LNX.4.64N.0610041931170.32103@attu2.cs.washington.edu>
	<20061004195313.892838e4.pj@sgi.com>
	<Pine.LNX.4.64N.0610041954470.642@attu2.cs.washington.edu>
	<20061004202656.18830f76.pj@sgi.com>
	<Pine.LNX.4.64N.0610042036230.27222@attu3.cs.washington.edu>
	<20061004210711.aefaea6c.akpm@osdl.org>
	<Pine.LNX.4.64N.0610042138580.5625@attu4.cs.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@cs.washington.edu>
Cc: akpm@osdl.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

> Usually memory is 
> going to be found in the first zone anyway and when it's not it's going to 
> be found next.

Agreed.  Usually.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 15 Feb 2005 07:11:50 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview
Message-Id: <20050215071150.0b5112e9.pj@sgi.com>
In-Reply-To: <20050215121552.GB20607@lnx-holt.americas.sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
	<m1vf8yf2nu.fsf@muc.de>
	<42114279.5070202@sgi.com>
	<20050215115302.GB19586@wotan.suse.de>
	<20050215121552.GB20607@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: ak@suse.de, raybry@sgi.com, ak@muc.de, raybry@austin.rr.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stevel@mvista.com
List-ID: <linux-mm.kvack.org>

Would it work to have the migration system call take exactly two node
numbers, the old and the new?  Have it migrate all pages in the address
space specified that are on the old node to the new node.  Leave any
other pages alone.  For one thing, this avoids passing a long list of
nodes, for an N-way to N-way migration. And for another thing, it seems
to solve some of the double migration and such issues.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

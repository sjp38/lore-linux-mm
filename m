Date: Tue, 15 Feb 2005 20:24:34 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: manual page migration -- issue list
Message-Id: <20050215202434.63d349ed.pj@sgi.com>
In-Reply-To: <20050216020138.GC28354@lnx-holt.americas.sgi.com>
References: <42128B25.9030206@sgi.com>
	<20050215165106.61fd4954.pj@sgi.com>
	<20050215171709.64b155ec.pj@sgi.com>
	<20050216020138.GC28354@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: raybry@sgi.com, linux-mm@kvack.org, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

Robin wrote:
> Overlapping nodes with the above will make
> a complete mess of your memory placement.

I agree we don't want to overlap nodes.

I don't yet understand why my simple (simplistic?)
version of this system call leads us to overlapped
nodes.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

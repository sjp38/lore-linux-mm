Date: Tue, 15 Feb 2005 16:09:27 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: manual page migration -- issue list
Message-Id: <20050215160927.7ab25ef7.pj@sgi.com>
In-Reply-To: <42128B25.9030206@sgi.com>
References: <42128B25.9030206@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: linux-mm@kvack.org, holt@sgi.com, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

One minor issue not mentioned:

  Is it more typical to pass the address range
  as a start and end address, or as a start address
  and a length?

I suspect the latter.

Though, by the time we get done on all this, who knows
if that minor issue will even apply any more.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

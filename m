Date: Sun, 21 Apr 2002 22:46:33 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: Why *not* rmap, anyway?
Message-ID: <3070690259.1019429192@[10.10.2.3]>
In-Reply-To: <3CC371CE.1EE4E264@earthlink.net>
References: <3CC371CE.1EE4E264@earthlink.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joseph A Knapka <jknapka@earthlink.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Because it costs something to maintain the reverse map.
>> If the cost exceeds the benefit, it's not worth it. That's
> 
> Sure, but it's not obvious (is it?) that the rmap cost
> exceeds the cost of scanning every process's virtual
> address space looking for pages to unmap.

No, but neither is it obvious that the cost of the virtual
scanning exceeds the cost of rmap ;-)

I think rmap will win in the end, but there's really only 
one way to prove it ;-)

M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Tue, 20 Apr 2004 04:16:21 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: numa api comments
Message-Id: <20040420041621.4e32cd6f.pj@sgi.com>
In-Reply-To: <295360000.1082413435@flay>
References: <20040419195447.GA5900@lst.de>
	<295360000.1082413435@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: hch@lst.de, ak@suse.de, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin groaned:
> I'd swear we had one of those already to iterate over 1 .. numnodes,
> but I can't find it. Grrr.

Are you thinking of Matthew Dobson's nodemask patch, which has
for_each_node() and a couple related loops, in include/linux/nodemask.h?

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

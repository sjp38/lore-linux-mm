Date: Sun, 19 Aug 2007 22:53:20 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: cpusets vs. mempolicy and how to get interleaving
Message-Id: <20070819225320.6562fbd1.pj@sgi.com>
In-Reply-To: <46C92AF4.20607@google.com>
References: <46C63BDE.20602@google.com>
	<46C63D5D.3020107@google.com>
	<alpine.DEB.0.99.0708190304510.7613@chino.kir.corp.google.com>
	<46C8E604.8040101@google.com>
	<20070819193431.dce5d4cf.pj@sgi.com>
	<46C92AF4.20607@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: rientjes@google.com, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ethan wrote:
> 	OK, then I'll proceed with a new MPOL. Do you believe that this will be 
> of general interest? i.e. worth placing in linux-mm?

I've no idea if it is of general interest or not.  I'm not interested ;).
But I'm just one person.

> 	BTW, a slightly different MPOL_INTERLEAVE implementation would help, 
> wherein we save the nodemask originally specified by the user and do the 
> remap from the original nodemask rather than the current nodemask.

I kinda like this idea; though keep in mind that since I don't use
mempolicy mechanisms, I am not loosing any sleep over minor(?)
compatibility breakages.  It would take someone familiar with the
actual users or usages of MPOL_INTERLEAVE to know if or how much
this would bite actual users/usages.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

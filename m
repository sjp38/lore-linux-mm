Date: Fri, 05 Sep 2003 12:44:40 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH 1/2] remap file pages MAP_NONBLOCK fix
Message-ID: <202200000.1062791080@flay>
In-Reply-To: <Pine.LNX.4.44.0309051545190.22540-100000@chimarrao.boston.redhat.com>
References: <Pine.LNX.4.44.0309051545190.22540-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Cc: Rajesh Venkatasubramanian <vrajesh@eecs.umich.edu>, akpm@osdl.org, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Or we could just kill remap_file_pages(), because it's a PITA to
>> maintain and it has maybe 10 legitimate users in the entire world...
> 
> It has its uses.  I just don't think it should support
> a non-mlocked VMA or deal with files being truncated.
> 
> The remap_file_pages we have in Taroon is pretty light
> weight. I hope the implementation in 2.6 will be
> simplified too ;)

We did actually agree to do this at Kernel Summit too ....

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

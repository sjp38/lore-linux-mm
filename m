Message-ID: <47FE523B.80100@cs.helsinki.fi>
Date: Thu, 10 Apr 2008 20:45:31 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: git-slub crashes on the t16p
References: <20080410015958.bc2fd041.akpm@linux-foundation.org> <Pine.LNX.4.64.0804101327190.15828@sbz-30.cs.Helsinki.FI> <47FE37D0.5030004@cs.helsinki.fi> <47FE41EE.8040402@cs.helsinki.fi> <20080410102454.8248e0ae.akpm@linux-foundation.org> <Pine.LNX.4.64.0804101029270.11781@schroedinger.engr.sgi.com> <47FE5137.4000605@cs.helsinki.fi>
In-Reply-To: <47FE5137.4000605@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> Actually, that's fixed in my tree since Saturday. So unfortunately I 
> don't think this is the problem...

Aah, it is, Andrew has this:

+	inc_slabs_node(s, node, page->objects);

Did I mess up my git tree or something? At least git clone gives me the 
correct results...

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

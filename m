Date: Fri, 25 Aug 2006 08:42:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] unify all architecture PAGE_SIZE definitions
In-Reply-To: <20060824234430.6AC970F7@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0608250838410.9083@schroedinger.engr.sgi.com>
References: <20060824234430.6AC970F7@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I think this is a good thing to do. However, the patch as it is now is 
difficult to review. Could you split the patch into multiple patches? One 
patch that introduces the generic functionality and then do one patch 
per arch? It would be best to sent the arch specific patches to the arch 
mailing list or the arch maintainer for review.

You probably can get the generic piece into mm together with the first 
arch specific patch (once the first arch has signed off) and then submit 
further bits as the reviews get completed.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

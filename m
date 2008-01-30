Date: Wed, 30 Jan 2008 10:13:05 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [-mm PATCH] updates for hotplug memory remove
In-Reply-To: <1201653101.19684.6.camel@dyn9047017100.beaverton.ibm.com>
References: <20080129120318.5BDF.Y-GOTO@jp.fujitsu.com> <1201653101.19684.6.camel@dyn9047017100.beaverton.ibm.com>
Message-Id: <20080130095002.4CCC.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

> > Have you ever tested hotadd(probe) of the removed memory?
> 
> Yes. I did. In my touch testing, I was able to remove memory and add
> it back to the system without any issues.

Oh, really!?

> But again, I didn't force
> the system to use that memory :(

Ah..OK.

> 
> > I'm afraid there are some differences of the status between pre hot-add
> > section and the removed section by this patch. I think the mem_section of
> > removed memory should be invalidated at least.
> 
> I think its a generic issue. Nothing specific for ppc64. Isn't it ? 

Right.
Currently, our machine doesn't have real physical remove feature yet.
(only add).
So, I think testing is not enough around physical removing.
Probably, your box will be first one which can remove physical memory
with Linux. It is good for testing. 
If you notice anything, please let me know. :-)


Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

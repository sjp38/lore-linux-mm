Date: Tue, 04 Mar 2003 17:43:33 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] remove __pte_offset
Message-ID: <635420000.1046828613@flay>
In-Reply-To: <20030304160150.7d67e011.akpm@digeo.com>
References: <3E653012.5040503@us.ibm.com><3E6530B3.2000906@us.ibm.com><20030304181002.A16110@redhat.com><629570000.1046819361@flay><20030304182652.B16110@redhat.com><3E653D69.8000007@us.ibm.com> <20030304160150.7d67e011.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: bcrl@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> While we're on the subject, does anyone else find the p*_offset
>> functions confusing?
> 
> How about sticking nice comments over them, rather than rampant renamings?

Would be nice if you could know what the thing did by just looking at
the caller rather than the definition. 

Remaning everything is probably bad, but the renames of __pgd_offset 
et al seem eminently sane to me, the fact that pgd_offset and __pgd_offset 
return different types seems like horrible confusion for no real reason
or benefit, especially when pgd_index already exists ...

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

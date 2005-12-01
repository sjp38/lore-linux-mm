Message-ID: <438E617F.4020005@gmail.com>
Date: Wed, 30 Nov 2005 20:35:43 -0600
From: Hareesh Nagarajan <hnagar2@gmail.com>
MIME-Version: 1.0
Subject: Re: Better pagecache statistics ?
References: <1133377029.27824.90.camel@localhost.localdomain>
In-Reply-To: <1133377029.27824.90.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

Badari Pulavarty wrote:
> - How much is just file system cache (regular file data) ?

This is just a thought of mine:
/proc/slabinfo?

> - How much is shared memory pages ?
> - How much is mmaped() stuff ?

cat /proc/vmstat | grep nr_mapped
nr_mapped 77105

But yes, this doesn't give you a detailed account.

> - How much is for text, data, bss, heap, malloc ?

Again, this is just a thought of mine: Couldn't you get this information 
from /proc/<pid>/maps or from the nicer and easier to parse procps 
application: pmap <pid>?

Thanks,

Hareesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Ray Bryant <raybry@sgi.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Date: Wed, 10 Nov 2004 12:50:59 -0600
Message-ID: <41926313.6010808__1767.91731869361$1100150605$gmane$org@sgi.com>
References: <200411081547.iA8FlH90124208@ben.americas.sgi.com> <41919EA5.7030200@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <41919EA5.7030200@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Russ Anderson <rja@sgi.com>, Matthew Wilcox <matthew@wil.cx>, "Martin J. Bligh" <mbligh@aracnet.com>, Christoph Lameter <clameter@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-Id: linux-mm.kvack.org

Nick Piggin wrote:

> 
> Also, are you using 2.6 kernels on these 512 CPU systems? or are your
> 2.4 kernels still holding together at that many CPUs?
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

We aren't supporting customers with 2.6 kernels yet.  NASA's systems are
all running kernels based on 2.4.x.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
